# frozen_string_literal: true

require 'rails_helper'

describe 'when filtering referenced relations from a scoped parent criteria' do
  before do
    CorrelatedRelationParent.delete_all
    CorrelatedRelationOwner.delete_all
    CorrelatedRelationProfile.delete_all
    CorrelatedRelationChild.delete_all

    @alpha_matching_owner = CorrelatedRelationOwner.create!(code: 'owner-alpha-match', tenant: 'alpha', name: 'matching')
    @alpha_other_owner = CorrelatedRelationOwner.create!(code: 'owner-alpha-other', tenant: 'alpha', name: 'other')
    @beta_matching_owner = CorrelatedRelationOwner.create!(code: 'owner-beta-match', tenant: 'beta', name: 'matching')

    @alpha_matching_parent = CorrelatedRelationParent.create!(
      lookup: 'parent-alpha-match', owner_code: @alpha_matching_owner.code, tenant: 'alpha', name: 'relation match'
    )
    @alpha_other_parent = CorrelatedRelationParent.create!(
      lookup: 'parent-alpha-other', owner_code: @alpha_other_owner.code, tenant: 'alpha', name: 'fallback'
    )
    @beta_matching_parent = CorrelatedRelationParent.create!(
      lookup: 'parent-beta-match', owner_code: @beta_matching_owner.code, tenant: 'beta', name: 'relation match'
    )

    CorrelatedRelationProfile.create!(parent_lookup: @alpha_matching_parent.lookup, tenant: 'alpha', status: 'active')
    CorrelatedRelationProfile.create!(parent_lookup: @alpha_other_parent.lookup, tenant: 'alpha', status: 'inactive')
    CorrelatedRelationProfile.create!(parent_lookup: @beta_matching_parent.lookup, tenant: 'beta', status: 'active')

    CorrelatedRelationChild.create!(
      parent_lookup: @alpha_matching_parent.lookup,
      reviewer_code: @alpha_matching_owner.code,
      tenant: 'alpha',
      status: 'active'
    )
    CorrelatedRelationChild.create!(
      parent_lookup: @alpha_other_parent.lookup,
      reviewer_code: @alpha_other_owner.code,
      tenant: 'alpha',
      status: 'inactive'
    )
    CorrelatedRelationChild.create!(
      parent_lookup: @beta_matching_parent.lookup,
      reviewer_code: @beta_matching_owner.code,
      tenant: 'beta',
      status: 'active'
    )

    @alpha_scope = CorrelatedRelationParent.where(tenant: 'alpha')
  end

  it 'should correlate belongs_to filters through custom foreign and primary keys' do
    result = Graphoid::Queries::Processor.execute(@alpha_scope, owner: { name: 'matching' })

    expect(result.pluck(:id)).to eq([@alpha_matching_parent.id])
  end

  it 'should correlate has_one filters through custom foreign and primary keys' do
    result = Graphoid::Queries::Processor.execute(@alpha_scope, profile: { status: 'active' })

    expect(result.pluck(:id)).to eq([@alpha_matching_parent.id])
  end

  it 'should preserve has_many some and none semantics inside the parent scope' do
    some = Graphoid::Queries::Processor.execute(@alpha_scope, children_some: { status: 'active' })
    none = Graphoid::Queries::Processor.execute(@alpha_scope, children_none: { status: 'active' })

    expect(some.pluck(:id)).to eq([@alpha_matching_parent.id])
    expect(none.pluck(:id)).to eq([@alpha_other_parent.id])
  end

  it 'should preserve the correlated scope through recursive and boolean filters' do
    filters = {
      'OR' => [
        { 'children_some' => { 'reviewer' => { 'name' => 'matching' } } },
        { 'name' => 'fallback' }
      ]
    }

    result = Graphoid::Queries::Processor.execute(@alpha_scope, filters)

    expect(result.pluck(:id)).to contain_exactly(@alpha_matching_parent.id, @alpha_other_parent.id)
  end

  it 'should authorize every recursively correlated target through the execution context' do
    provider = CorrelatedRelationScopeProvider.new(@alpha_matching_owner.code)
    context = Graphoid::Queries::ExecutionContext.new(provider)
    filters = {
      'AND' => [
        {
          'OR' => [
            { 'children_some' => { 'reviewer' => { 'name' => 'matching' } } },
            { 'name' => 'missing' }
          ]
        }
      ]
    }

    result = Graphoid::Queries::Processor.execute(@alpha_scope, filters, context: context)

    expect(result).to be_empty
    expect(provider.relations).to include(:children, :reviewer)
  end

  it 'should apply every to all authorized correlated children with vacuous truth' do
    empty_parent = CorrelatedRelationParent.create!(
      lookup: 'parent-alpha-empty',
      owner_code: @alpha_other_owner.code,
      tenant: 'alpha',
      name: 'empty'
    )

    result = Graphoid::Queries::Processor.execute(@alpha_scope, children_every: { status: 'active' })

    expect(result.pluck(:id)).to contain_exactly(@alpha_matching_parent.id, empty_parent.id)
  end

  it 'should leave ordering and pagination on the returned criteria after relation filtering' do
    paginated_scope = @alpha_scope.order(name: :asc).limit(1)

    result = Graphoid::Queries::Processor.execute(paginated_scope, owner: { name: 'matching' })

    expect(result).to be_a(Mongoid::Criteria)
    expect(result.pluck(:id)).to eq([@alpha_matching_parent.id])
  end

  it 'should use key-only aggregations and restrict target candidates to reachable parent keys' do
    subscriber = RelationCommandSubscriber.new
    client = Mongoid.default_client
    client.subscribe(Mongo::Monitoring::COMMAND, subscriber)

    Graphoid::Queries::Processor.execute(@alpha_scope, owner: { name: 'matching' }).to_a

    owner_aggregates = subscriber.started_events.select do |event|
      event.command_name.to_s == 'aggregate' &&
        event.command['aggregate'] == CorrelatedRelationOwner.collection_name.to_s
    end
    owner_finds = subscriber.started_events.select do |event|
      event.command_name.to_s == 'find' &&
        event.command['find'] == CorrelatedRelationOwner.collection_name.to_s
    end

    expect(owner_finds).to be_empty
    expect(owner_aggregates.length).to eq(1)

    pipeline = owner_aggregates.first.command['pipeline']
    expect(pipeline).to include('$project' => { '__graphoid_key' => '$code' })
    expect(pipeline).to include('$group' => { '_id' => '$__graphoid_key' })
    reachable_owner_codes = pipeline.first.fetch('$match').fetch('code').fetch('$in')
    expect(reachable_owner_codes).to contain_exactly(@alpha_matching_owner.code, @alpha_other_owner.code)
    expect(reachable_owner_codes).not_to include(@beta_matching_owner.code)
  ensure
    client&.unsubscribe(Mongo::Monitoring::COMMAND, subscriber)
  end

  it 'should fail deterministically before querying targets when reachable key cardinality exceeds the limit' do
    previous_limit = Graphoid.configuration.relation_filter_max_keys
    Graphoid.configuration.relation_filter_max_keys = 1

    expect do
      Graphoid::Queries::Processor.execute(@alpha_scope, owner: { name: 'matching' })
    end.to raise_error(
      Graphoid::RelationFilterCardinalityError,
      'Relation filter exceeded 1 distinct keys for CorrelatedRelationParent.owner_code'
    )
  ensure
    Graphoid.configuration.relation_filter_max_keys = previous_limit
  end
end

class RelationCommandSubscriber
  attr_reader :started_events

  def initialize
    @started_events = []
  end

  def started(event)
    started_events << event
  end

  def succeeded(_event); end

  def failed(_event); end
end

class CorrelatedRelationScopeProvider
  attr_reader :relations

  def initialize(excluded_owner_code)
    @excluded_owner_code = excluded_owner_code
    @relations = []
  end

  def scope_for(model, relation:, parent_scope:)
    relations << relation.name
    return model.all unless model == CorrelatedRelationOwner

    model.where(:code.nin => [@excluded_owner_code])
  end
end

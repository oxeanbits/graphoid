# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'when querying generated relations' do
  def validation_message(query)
    TesterMongoSchema.validate(query).first&.message
  end

  describe 'when filtering by an opted-in relation' do
    {
      'belongs_to' => '{ people(where: { account: { id_not: null } }) { id } }',
      'has_one' => '{ accounts(where: { person: { id_not: null } }) { id } }',
      'has_many _some' => '{ accounts(where: { labels_some: { id_not: null } }) { id } }',
      'has_many _none' => '{ accounts(where: { labels_none: { id_not: null } }) { id } }',
      'has_many _every' => '{ accounts(where: { labels_every: { id_not: null } }) { id } }',
      'has_and_belongs_to_many' => '{ users(where: { accounts_some: { id_not: null } }) { id } }',
      'self-referencing has_and_belongs_to_many' => '{ users(where: { dependencies_some: { id_not: null } }) { id } }',
      'embeds_one' => '{ accounts(where: { value: { id_not: null } }) { id } }',
      'embeds_many' => '{ accounts(where: { snakes_some: { id_not: null } }) { id } }'
    }.each do |relation_kind, query|
      it "should accept the #{relation_kind} relation filter" do
        expect(TesterMongoSchema.validate(query)).to be_empty
      end
    end
  end

  describe 'when filtering by a relation that is not opted in' do
    {
      'belongs_to' => ['{ accounts(where: { house: { id_not: null } }) { id } }', 'house'],
      'has_many _some' => ['{ houses(where: { accounts_some: { id_not: null } }) { id } }', 'accounts_some'],
      'has_many _none' => ['{ houses(where: { accounts_none: { id_not: null } }) { id } }', 'accounts_none'],
      'has_many _every' => ['{ houses(where: { accounts_every: { id_not: null } }) { id } }', 'accounts_every'],
      'has_and_belongs_to_many' => ['{ accounts(where: { users_some: { id_not: null } }) { id } }', 'users_some'],
      'self-referencing has_and_belongs_to_many' => ['{ users(where: { dependents_some: { id_not: null } }) { id } }', 'dependents_some']
    }.each do |relation_kind, (query, argument)|
      it "should reject the #{relation_kind} relation filter" do
        expect(validation_message(query)).to include("doesn't accept argument '#{argument}'")
      end
    end
  end

  describe 'when filtering the results of a selected relation' do
    {
      'opted-in has_many' => '{ accounts { labels(where: { id_not: null }) { id } } }',
      'has_many' => '{ houses { accounts(where: { id_not: null }) { id } } }',
      'has_and_belongs_to_many' => '{ accounts { users(where: { id_not: null }) { id } } }',
      'opted-in has_and_belongs_to_many' => '{ users { dependencies(where: { id_not: null }) { id } } }',
      'opted-in embeds_many' => '{ accounts { snakes(where: { id_not: null }) { id } } }'
    }.each do |relation_kind, query|
      it "should reject where on the selected #{relation_kind} relation" do
        expect(validation_message(query)).to include("doesn't accept argument 'where'")
      end
    end
  end

  describe 'when selecting a relation without filtering its results' do
    it 'should accept scalar filters with ordering and pagination' do
      errors = TesterMongoSchema.validate(<<~GRAPHQL)
        {
          accounts(where: { stringField: "account" }) {
            labels(order: { id: ASC }, limit: 1, skip: 0) { id }
          }
        }
      GRAPHQL

      expect(errors).to be_empty
    end
  end
end

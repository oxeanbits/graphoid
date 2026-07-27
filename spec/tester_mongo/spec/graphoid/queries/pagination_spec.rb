# frozen_string_literal: true

require 'rails_helper'

describe GraphqlController, type: :controller do
  before { Level.delete_all }
  describe 'POST #execute' do
    let(:query) do |example|
      limit = example.metadata[:limit]
      skip_param = example.metadata[:skip_param]

      <<-GRAPHQL
        {
          levels(where: { name_contains: "1", createdAt_gt: "2023-04-01" }, order: { name: DESC}, limit: #{limit}, skip: #{skip_param}) {
            count
            pageSize
            pages
            data {
              id
              name
              createdAt
            }
          }
        }
      GRAPHQL
    end

    let!(:level1) { Level.create!(name: 'Level 1A', created_at: '2023-04-02') }
    let!(:level2) { Level.create!(name: 'Level 1B', created_at: '2023-04-03') }
    let!(:level3) { Level.create!(name: 'Level 1C', created_at: '2023-04-04') }
    let!(:level4) { Level.create!(name: 'Level 2A', created_at: '2023-04-02') }

    context 'with valid query', limit: 2, skip_param: 0 do
      before do
        post :execute, params: { query: query }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'returns the expected levels' do
        expect(JSON.parse(response.body)['data']['levels']).to match(
          'count' => 3,
          'pageSize' => 2,
          'pages' => 2,
          'data' => [
            {
              'id' => level3.id.to_s,
              'name' => level3.name,
              'createdAt' => level3.created_at.iso8601(3)
            },
            {
              'id' => level2.id.to_s,
              'name' => level2.name,
              'createdAt' => level2.created_at.iso8601(3)
            }
          ]
        )
      end
    end

    context 'with different pagination params', limit: 1, skip_param: 1 do
      before do
        post :execute, params: { query: query }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'returns the expected levels' do
        expect(JSON.parse(response.body)['data']['levels']).to match(
          'count' => 3,
          'pageSize' => 1,
          'pages' => 3,
          'data' => [
            {
              'id' => level2.id.to_s,
              'name' => level2.name,
              'createdAt' => level2.created_at.iso8601(3)
            }
          ]
        )
      end
    end

    context 'with a paginated data model hook', limit: 2, skip_param: 0 do
      let(:hook_arguments) { {} }

      before do
        arguments = hook_arguments
        hook_result = [level2]
        Level.define_singleton_method(:graphoid_load_paginated_data) do |scope, lookahead:|
          arguments[:scope] = scope
          arguments[:lookahead] = lookahead
          hook_result
        end

        post :execute, params: { query: query }
      end

      after do
        Level.singleton_class.remove_method(:graphoid_load_paginated_data)
      end

      it 'passes the resolved scope and lookahead directly to the model' do
        expect(hook_arguments[:scope]).to be_a(Mongoid::Criteria)
        expect(hook_arguments[:scope].options).to include(limit: 2, skip: 0)
        selected_fields = hook_arguments[:lookahead].selections.map { |selection| selection.field.name }

        expect(selected_fields).to contain_exactly('id', 'name', 'createdAt')
      end

      it 'uses the collection returned by the model hook' do
        expect(JSON.parse(response.body)['data']['levels']['data']).to contain_exactly(
          {
            'id' => level2.id.to_s,
            'name' => level2.name,
            'createdAt' => level2.created_at.iso8601(3)
          }
        )
      end
    end

    context 'with legacy model loading methods', limit: 2, skip_param: 0 do
      before do
        Level.define_singleton_method(:lookahead) { |*, **| raise 'legacy lookahead called' }
        Level.define_singleton_method(:eager_load) { |*, **| raise 'legacy eager_load called' }

        post :execute, params: { query: query }
      end

      after do
        Level.singleton_class.remove_method(:lookahead)
        Level.singleton_class.remove_method(:eager_load)
      end

      it 'does not dispatch pagination loading through criteria methods' do
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['errors']).to be_nil
      end
    end
  end
end

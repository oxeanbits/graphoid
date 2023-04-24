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
  end
end

require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  describe 'POST #execute' do
    before do
      User.delete_all
      Project.delete_all
    end
    let(:query) do
      <<-GRAPHQL
        {
          projects(order:{ name: ASC }, where: { active: true }) {
            id
            name
            active
            users(where: { nameContains: "i" }, order: { name: DESC}) { id }
          }
        }
      GRAPHQL
    end

    let!(:project1) { Project.create!(name: 'Project A', active: true) }
    let!(:project2) { Project.create(name: 'Project B', active: false, users: [user3]) }
    let!(:project3) { Project.create!(name: 'Project C', active: true) }

    let!(:user1) { User.create!(name: 'charlie', email: 'charlie@gmail.com',
                                project_id: project1.id, project_ids: [project1.id],
                                password: '12345678', password_confirmation: '12345678') }
    let!(:user2) { User.create!(name: 'alice', email: 'alice@gmail.com',
                                project_id: project1.id, project_ids: [project1.id],
                                password: '12345678', password_confirmation: '12345678') }
    let!(:user3) { User.create!(name: 'bob', email: 'bob@gmail.com',
                                project_id: project3.id, project_ids: [project3.id],
                                password: '12345678', password_confirmation: '12345678') }

    context 'with valid query' do
      before do
        post :execute, params: { query: query }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'returns the expected projects' do
        expect(JSON.parse(response.body)['data']['projects']).to match_array([
          {
            'id' => project1.id.to_s,
            'name' => project1.name,
            'active' => project1.active,
            'users' => [
              { 'id' => user1.id.to_s },
              { 'id' => user2.id.to_s }
            ]
          },
          {
            'id' => project3.id.to_s,
            'name' => project3.name,
            'active' => project3.active,
            'users' => []
          }
        ])
      end
    end

    context 'with invalid query' do
      let(:invalid_query) { 'invalid query' }

      before do
        post :execute, params: { query: invalid_query }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'returns an error message' do
        expect(JSON.parse(response.body)['errors']).not_to be_empty
      end
    end
  end
end

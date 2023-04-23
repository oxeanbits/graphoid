# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  before do
    User.delete_all
    Project.delete_all
  end

  describe 'POST #execute projects' do
    let(:query) do
      <<-GRAPHQL
        {
          projects(order:{ name: ASC }, where: { active: true }) {
            id
            name
            active
            users(where: { name_contains: "i" }, order: { name: DESC}) { id }
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

  describe 'POST #execute users' do
    let(:query) do
      <<-GRAPHQL
        {
          users(where: { project: { name_contains: "BK" }}) {
            name
            email
            active
            projectId
            projectIds
            project { id name }
          }
        }
      GRAPHQL
    end

    let!(:project1) { Project.create!(name: 'Project BK-A', active: true) }
    let!(:project2) { Project.create(name: 'Project BK-B', active: true) }
    let!(:project3) { Project.create!(name: 'Project C', active: true) }

    let!(:user1) { User.create!(name: 'alice', email: 'alice@gmail.com',
                                project_id: project1.id, project_ids: [project1.id.to_s],
                                password: '12345678', password_confirmation: '12345678') }
    let!(:user2) { User.create!(name: 'charlie', email: 'charlie@gmail.com',
                                project_id: project2.id, project_ids: [project2.id.to_s],
                                password: '12345678', password_confirmation: '12345678') }
    let!(:user3) { User.create!(name: 'bob', email: 'bob@gmail.com',
                                project_id: project3.id, project_ids: [project3.id.to_s],
                                password: '12345678', password_confirmation: '12345678') }

    context 'with valid query' do
      before do
        post :execute, params: { query: query }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'returns the expected users' do
        expect(JSON.parse(response.body)['data']['users']).to match_array([
          {
            'name' => user1.name,
            'email' => user1.email,
            'active' => user1.active,
            'projectId' => project1.id.to_s,
            'projectIds' => [project1.id.to_s],
            'project' => { 'id' => project1.id.to_s, 'name' => project1.name }
          },
          {
            'name' => user2.name,
            'email' => user2.email,
            'active' => user2.active,
            'projectId' => project2.id.to_s,
            'projectIds' => [project2.id.to_s],
            'project' => { 'id' => project2.id.to_s, 'name' => project2.name }
          }
        ])
      end
    end
  end

  describe 'POST #execute users using OR filters' do
    let(:query) do
      <<-GRAPHQL
        {
          users(where: { OR: [
            {project: { name_contains: "BK" }}, {project: { name_contains: "Ox" }}
          ]}) {
            name
          }
        }
      GRAPHQL
    end

    let!(:project1) { Project.create!(name: 'Project BK-A', active: true) }
    let!(:project2) { Project.create(name: 'Project Ox-B', active: true) }
    let!(:project3) { Project.create!(name: 'Project C', active: true) }

    let!(:user1) { User.create!(name: 'alice', email: 'alice@gmail.com',
                                project_id: project1.id, project_ids: [project1.id.to_s],
                                password: '12345678', password_confirmation: '12345678') }
    let!(:user2) { User.create!(name: 'charlie', email: 'charlie@gmail.com',
                                project_id: project2.id, project_ids: [project2.id.to_s],
                                password: '12345678', password_confirmation: '12345678') }
    let!(:user3) { User.create!(name: 'bob', email: 'bob@gmail.com',
                                project_id: project3.id, project_ids: [project3.id.to_s],
                                password: '12345678', password_confirmation: '12345678') }

    context 'with valid query' do
      before do
        post :execute, params: { query: query }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'returns the expected users' do
        expect(JSON.parse(response.body)['data']['users']).to match_array([
          {
            'name' => user1.name,
          },
          {
            'name' => user2.name,
          }
        ])
      end
    end
  end

  describe 'POST #execute create user' do
    let!(:project) { Project.create!(name: 'Project A', active: true) }

    let(:mutation) do
      <<-GRAPHQL
        mutation {
          createUser(data: {
            name: "Zeca"
            email: "zecay@gmail.com"
            password: "123456"
            passwordConfirmation: "123456"
            projectId: "#{project.id}"
            projectIds: ["#{project.id}"]
          }) {
            id
            name
          }
        }
      GRAPHQL
    end

    context 'with valid mutation' do
      before do
        post :execute, params: { query: mutation }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'creates a new user' do
        expect(User.count).to eq(1)
      end

      it 'returns the created user' do
        created_user = User.last
        expect(JSON.parse(response.body)['data']['createUser']).to match(
          'id' => created_user.id.to_s,
          'name' => created_user.name
        )
      end
    end

    context 'with invalid mutation' do
      let(:invalid_mutation) do
        <<-GRAPHQL
          mutation {
            createUser(data: {
              name: "Zeca"
              email: "zecay@gmail.com"
              password: "123456"
              passwordConfirmation: "654321"
              projectId: "#{project.id}"
              projectIds: ["#{project.id}"]
            }) {
              id
              name
            }
          }
        GRAPHQL
      end

      before do
        post :execute, params: { query: invalid_mutation }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'does not create a new user' do
        expect(User.count).to eq(0)
      end

      it 'returns an error message' do
        expect(JSON.parse(response.body)['errors']).not_to be_empty
      end
    end
  end
end

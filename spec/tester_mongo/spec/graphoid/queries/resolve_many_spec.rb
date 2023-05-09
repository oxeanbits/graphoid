# frozen_string_literal: true

require 'rails_helper'

describe GraphqlController, type: :controller do
  before { Player.delete_all }
  describe 'POST #execute' do
    let(:query) do |example|
      limit = example.metadata[:limit]
      skip_param = example.metadata[:skip_param]

      <<-GRAPHQL
        {
          players(where: { email_contains: "player" }) {
            id
            name
            email
          }
        }
      GRAPHQL
    end

    let!(:player1) { Player.create!(name: 'Player 1A', email: 'player1a@gmail.com') }
    let!(:player2) { Player.create!(name: 'Player 1B', email: 'player1b@gmail.com') }
    let!(:player3) { Player.create!(name: 'Player 1C', email: 'player1c@dbz.com', active: false) }
    let!(:player4) { Player.create!(name: 'Player 2A', email: 'player2a@dbz.com', active: false) }

    context 'with valid query', limit: 2, skip_param: 0 do
      before do
        post :execute, params: { query: query }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'returns the expected levels' do
        expect(JSON.parse(response.body)['data']['players']).to match(
          [
            {
              'id' => player1.id.to_s,
              'name' => player1.name,
              'email' => player1.email,
            },
            {
              'id' => player2.id.to_s,
              'name' => player2.name,
              'email' => player2.email,
            }
          ]
        )
      end
    end
  end
end

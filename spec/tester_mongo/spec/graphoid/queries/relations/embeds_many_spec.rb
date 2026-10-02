# frozen_string_literal: true

require 'rails_helper'

describe 'QueryEmbedsMany', type: :request do
  let!(:delete) { Account.delete_all; }
  subject { Helper.resolve(self, 'accounts', @query) }

  let!(:a0) do
    Account.create!(string_field: 'bob', snakes: [])
  end
  let!(:a1) do
    Account.create!(string_field: 'bob', snakes: [])
  end
  let!(:a2) do
    Account.create!(string_field: 'boc', snakes: [])
  end

  let!(:s0) { Snake.create!(name: 'a', camelCase: 1, snake_case: 1.0, account: a0) }
  let!(:s1) { Snake.create!(name: 'a', camelCase: 2, snake_case: 1.0, account: a0) }
  let!(:s2) { Snake.create!(name: 'b', camelCase: 1, snake_case: 1.0, account: a1) }
  let!(:s3) { Snake.create!(name: 'b', camelCase: 2, snake_case: 2.0, account: a1) }
  let!(:s4) { Snake.create!(name: 'c', camelCase: 1, snake_case: 1.0, account: a2) }
  let!(:s5) { Snake.create!(name: 'a', camelCase: 2, snake_case: 2.0, account: a2) }

  describe 'filtering with conditions in embeds_many relations' do
    it 'filters _some' do
      @query = %{
        query {
          accounts(where: {
            stringField: "bob",
            snakes_some: { name: "a", camelCase: 1 }
          }) {
            id
            snakes {
              id
            }
          }
        }
      }

      expect(subject.size).to eq(1)
      expect(subject[0]['id']).to eq a0.id.to_s
      expect(subject[0]['snakes'][0]['id']).to eq s0.id.to_s
      expect(subject[0]['snakes'][1]['id']).to eq s1.id.to_s
    end
  end
end

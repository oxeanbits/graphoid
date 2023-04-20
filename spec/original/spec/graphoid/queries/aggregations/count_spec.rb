# frozen_string_literal: true

require 'rails_helper'

describe 'QueryAndCount', type: :request do
  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, 'xMetaAccounts', @query)['count'] }

  let!(:a0) { Account.create!(snake_case: 'snaki', camelCase: 'camol') }
  let!(:a1) { Account.create!(snake_case: 'snaki', camelCase: 'camol') }
  let!(:a2) { Account.create!(snake_case: 'snaki', camelCase: 'camol') }
  let!(:a3) { Account.create!(snake_case: 'snake', camelCase: 'camel') }
  let!(:a4) { Account.create!(snake_case: 'snake', camelCase: 'camel') }

  describe 'count on models' do
    it 'with a string camelCased field' do
      @query = %(
        query {
          xMetaAccounts {
            count
          }
        }
      )

      expect(subject).to eq 5
    end

    it 'with a filter' do
      @query = %{
        query {
          xMetaAccounts(where: {
            snakeCase_contains: "ki"
          }) {
            count
          }
        }
      }

      expect(subject).to eq 3
    end
  end
end

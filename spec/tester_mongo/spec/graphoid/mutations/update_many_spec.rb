# frozen_string_literal: true

require 'rails_helper'

describe 'MutationUpdateMany', type: :request do
  def query(value)
    %{
      mutation M {
        updateManyAccounts(where: { snakeCase: "snake" }, data: { camelCase: "#{value}" }){
          id
          camelCase
        }
      }
    }
  end

  before { Account.delete_all }
  subject { Helper.resolve(self, 'updateManyAccounts', query('updated')) }

  let!(:a0) { Account.create!(string_field: 'account0', snake_case: 'snake', camelCase: 'camel') }
  let!(:a1) { Account.create!(string_field: 'account1', snake_case: 'snake', camelCase: 'camel') }
  let!(:a2) { Account.create!(string_field: 'account2', snake_case: 'snaki', camelCase: 'camel') }

  it 'updates many objects by condition' do
    expect(subject[0]['camelCase']).to eq('updated')
    expect(subject[1]['camelCase']).to eq('updated')
    expect(a0.reload.camelCase).to eq('updated')
    expect(a1.reload.camelCase).to eq('updated')
    expect(a2.reload.camelCase).to eq('camel')
  end

  describe 'when there are errors in the mutation execution' do
    before do
      Account.class_eval do
        def self.resolve_filter(resolver, result)
          msg = 'User has insufficient privileges for this operation'
          raise GraphQL::ExecutionError, msg
        end
      end

      @result = Helper.resolve(self, 'updateManyAccounts', query('edimar'))
    end

    it 'should block the operation' do
      expect(response.body).to include('User has insufficient privileges for this operation')
    end
  end
end

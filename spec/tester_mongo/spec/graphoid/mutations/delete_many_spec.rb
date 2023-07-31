# frozen_string_literal: true

require 'rails_helper'

describe 'MutationDeleteMany', type: :request do
  def query(value)
    %{
      mutation {
        deleteManyAccounts(where: { stringField: "#{value}" }){
          id
          stringField
        }
      }
    }
  end

  before { Account.delete_all }
  subject { Helper.resolve(self, 'deleteManyAccounts', query('bob')) }

  let!(:a0) { Account.create!(string_field: 'bob') }
  let!(:a1) { Account.create!(string_field: 'bob') }
  let!(:a2) { Account.create!(string_field: 'oob') }

  it 'deletes many objects by condition' do
    expect(Account.count).to eq(3)
    subject
    expect(Account.count).to eq(1)
    expect(Account.first.string_field).to eq('oob')
  end

  describe 'when there are errors in the mutation execution' do
    before do
      Account.class_eval do
        def self.resolve_filter(resolver, result)
          msg = 'User has insufficient privileges for this operation'
          raise GraphQL::ExecutionError, msg
        end
      end

      @result = Helper.resolve(self, 'deleteManyAccounts', query('edimar'))
    end

    after do
      Account.class_eval do
        def self.resolve_filter(resolver, result)
          result
        end
      end
    end

    it 'should block the operation' do
      expect(response.body).to include('User has insufficient privileges for this operation')
    end
  end
end

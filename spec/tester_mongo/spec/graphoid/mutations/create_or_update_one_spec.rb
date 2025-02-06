# frozen_string_literal: true

require 'rails_helper'

describe 'MutationCreateOrUpdate', type: :request do
  before { Account.delete_all }
  subject { Helper.resolve(self, 'createOrUpdateAccount', @query) }

  it 'creates an object if one does not exist' do
    @query = %{
      mutation {
        createOrUpdateAccount(
        where: { integerField: 5 }
        data: {
          integerField: 3,
          floatField: 3.2,
        }) {
          id
        }
      }
    }

    persisted = Account.find(subject['id'])
    expect(persisted).not_to be_nil
    expect(persisted.float_field).to eq(3.2)
  end

  it 'updates an existing object if one exists' do
    existing = Account.create!(integer_field: 5, float_field: 2.0)
    @query = %{
      mutation {
        createOrUpdateAccount(
        where: { integerField: 5 }
        data: {
          integerField: 5,
          floatField: 3.2,
        }) {
          id
        }
      }
    }

    subject
    existing.reload

    expect(existing.float_field).to eq(3.2)
  end

  it 'does not affect other objects' do
    existing1 = Account.create!(integer_field: 5, float_field: 2.0)
    existing2 = Account.create!(integer_field: 4, float_field: 3.0)

    @query = %{
      mutation {
        createOrUpdateAccount(
        where: { integerField: 5 }
        data: {
          integerField: 5,
          floatField: 3.2,
        }) {
          id
        }
      }
    }

    subject
    existing1.reload
    existing2.reload

    expect(existing1.float_field).to eq(3.2)
    expect(existing2.float_field).to eq(3.0)
  end

  context 'when there are multiple matching records' do
    it 'updates only the first matching record' do
      existing1 = Account.create!(integer_field: 5, float_field: 2.0)
      existing2 = Account.create!(integer_field: 5, float_field: 3.0)

      @query = %{
        mutation {
          createOrUpdateAccount(
          where: { integerField: 5 }
          data: {
            integerField: 5,
            floatField: 3.2,
          }) {
            id
          }
        }
      }

      subject
      existing1.reload
      existing2.reload

      expect(existing1.float_field).to eq(3.2)
      expect(existing2.float_field).to eq(3.0)
    end
  end

  context 'intercepting the matching record' do
    it 'does not find the matching record and creates an object' do
      existing = Account.create!(string_field: 'hook', integer_field: 5)
      
      @query = %{
        mutation {
          createOrUpdateAccount(
          where: { integerField: 5 }
          data: {
            floatField: 3.2,
          }) {
            id
          }
        }
      }

      subject
      existing.reload
      persisted = Account.find(subject['id'])

      expect(existing.float_field).to be_nil
      expect(persisted.float_field).to eq(3.2)
    end
  end
end

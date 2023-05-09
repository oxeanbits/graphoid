# frozen_string_literal: true

require 'rails_helper'

describe 'MutationCreateNested', type: :request do
  before { Account.delete_all }
  subject { Helper.resolve(self, 'createAccount', @query) }

  it 'creates one object with referenced relations' do
    @query = %{
      mutation {
        createAccount(data: {
          stringField: "bob",
          person: { name: "Bryan" },
          snakes: [{ name: "a", camelCase: 1 }, { name: "b", camelCase: 2 }],
          value: { text: "a", name: "b", valueNested: [{ text: "c", name: "d" }] }
          house: { name: "Alesi" }
        }) {
          id
          person {
            id
          }
          snakes {
            id
          }
        }
      }
    }

    persisted = Account.find(subject['id'])
    persisted.reload

    expect(persisted.snakes.size).to be_eql(2)
    expect(persisted.snakes.first.name).to be_eql('a')
    expect(persisted.snakes.first.camelCase).to be_eql(1)
    expect(persisted.snakes.last.name).to be_eql('b')
    expect(persisted.snakes.last.camelCase).to be_eql(2)
    expect(persisted.person.name).to eq('Bryan')
  end
end

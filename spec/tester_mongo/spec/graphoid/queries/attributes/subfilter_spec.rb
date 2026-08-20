# frozen_string_literal: true

# TODO: should apply submodel filtering on embeeded relations
# TODO: elaborate more complex cases

require 'rails_helper'

describe 'QuerySubFilter', type: :request do
  subject { Helper.resolve(self, @action, @query) }

  before(:all) do
    Person.delete_all
    Label.delete_all
    Account.delete_all
    House.delete_all

    @h0 = House.create!(name: 'h0')
    @a0 = Account.create!(integer_field: 2, house: @h0)
    @p0 = Person.create!(account: @a0, name: 'p0', snake_case: 'snake', camelCase: 'camel')
    @l0 = Label.create!(account: @a0, name: 'l0', amount: 2)
    @l1 = Label.create!(account: @a0, name: 'l1', amount: 2)
  end

  after(:all) do
    [@h0, @a0, @p0, @l0, @l1].map(&:destroy)
  end

  describe 'when selecting related models' do
    it 'should return all has-many relations after a scalar root filter' do
      @action = 'accounts'
      @query = %{
        query {
          accounts(where: { integerField: 2 }) {
            id
            labels {
              id
            }
          }
        }
      }

      expect(subject.size).to eq(1)
      label_ids = subject[0]['labels'].map { |label| label['id'] }
      expect(label_ids).to contain_exactly(@l0.id.to_s, @l1.id.to_s)
    end
  end
end

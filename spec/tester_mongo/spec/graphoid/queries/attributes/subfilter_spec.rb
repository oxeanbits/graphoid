# frozen_string_literal: true

require 'rails_helper'

describe 'QuerySubFilter' do
  describe 'when filtering a selected relation' do
    it 'should reject where on a has-many relation' do
      errors = TesterMongoSchema.validate(<<~GRAPHQL)
        query {
          accounts {
            id
            labels(where: { amount: 2, name: "l0" }) {
              id
            }
          }
        }
      GRAPHQL

      expect(errors.first.message).to include("Field 'labels' doesn't accept argument 'where'")
    end
  end
end

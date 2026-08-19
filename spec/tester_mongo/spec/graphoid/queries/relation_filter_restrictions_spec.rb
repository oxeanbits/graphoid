# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'when querying generated relations' do
  def validation_errors(query)
    TesterMongoSchema.validate(query)
  end

  def expect_argument_not_accepted(query, argument)
    error = validation_errors(query).first

    expect(error.message).to include("doesn't accept argument '#{argument}'")
  end

  it 'should reject a one-valued relation filter' do
    expect_argument_not_accepted(
      '{ people(where: { account: { id_not: null } }) { id } }',
      'account'
    )
  end

  %w[some none every].each do |operator|
    it "should reject a to-many #{operator} relation filter" do
      expect_argument_not_accepted(
        "{ accounts(where: { labels_#{operator}: { id_not: null } }) { id } }",
        "labels_#{operator}"
      )
    end
  end

  it 'should reject where on a selected to-many relation' do
    expect_argument_not_accepted(
      '{ accounts { labels(where: { name: "label" }) { id } } }',
      'where'
    )
  end

  it 'should allow scalar filters and unfiltered relation selection' do
    errors = validation_errors(<<~GRAPHQL)
      {
        accounts(where: { stringField: "account" }) {
          labels(order: { id: ASC }, limit: 1, skip: 0) { id }
        }
      }
    GRAPHQL

    expect(errors).to be_empty
  end
end

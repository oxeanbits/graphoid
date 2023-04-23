# frozen_string_literal: true

class ExampleType < GraphQL::Schema::Object
  graphql_name "Example"

  field :date_time, Graphoid::Scalars::DateTime, null: false, description: "A DateTime value"
  field :date, Graphoid::Scalars::Date, null: false, description: "A Date value"
  field :time, Graphoid::Scalars::Time, null: false, description: "A Time value"
  field :timestamp, Graphoid::Scalars::Timestamp, null: false, description: "A Timestamp value"
  field :text, Graphoid::Scalars::Text, null: false, description: "A Text value"
  field :big_int, Graphoid::Scalars::BigInt, null: false, description: "A BigInt value"
  field :decimal, Graphoid::Scalars::Decimal, null: false, description: "A Decimal value"
  field :hash_field, Graphoid::Scalars::Hash, null: false, description: "A Hash value"
  field :array, Graphoid::Scalars::Array, null: false, description: "An Array value"
end

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"

    field :example, ExampleType, null: true, description: "Using all scalar types"

    def test_field
      "Hello World!"
    end

    def example
      {
        date_time: DateTime.now,
        date: Date.today,
        time: Time.now,
        timestamp: Time.now.to_i,
        text: "Some example text",
        big_int: 12345678901234567890,
        decimal: BigDecimal("123.456"),
        hash_field: { key: "value" },
        array: [1, 2, 3]
      }
    end
  end
end

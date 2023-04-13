module Graphoid
  module Scalars
    class << self
      def generate
        Graphoid::Scalars::DateTime ||= Class.new(GraphQL::Schema::Scalar) do
          graphql_name 'DateTime'
          description 'DateTime ISO8601 formated'

          def self.coerce_input(value, _ctx)
            begin
              ::DateTime.iso8601(value)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex)
            end
          end
        end

        Graphoid::Scalars::Date ||= Class.new(GraphQL::Schema::Scalar) do
          graphql_name 'Date'
          description 'Date ISO8601 formated'

          def self.coerce_input(value, _ctx)
            begin
              ::DateTime.iso8601(value)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex)
            end
          end
        end

        Graphoid::Scalars::Time ||= Class.new(GraphQL::Schema::Scalar) do
          graphql_name 'Time'
          description 'Time ISO8601 formated'

          def self.coerce_input(value, _ctx)
            begin
              ::DateTime.iso8601(value)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex)
            end
          end
        end

        Graphoid::Scalars::Timestamp ||= Class.new(GraphQL::Schema::Scalar) do
          graphql_name 'Timestamp'
          description 'Second elapsed since 1970-01-01'

          def self.coerce_input(value, _ctx)
            begin
              ::DateTime.iso8601(value)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex)
            end
          end
        end

        Graphoid::Scalars::Text ||= Class.new(GraphQL::Schema::Scalar) do
          graphql_name 'Text'
          description 'Should be string? explain this please.'
        end

        Graphoid::Scalars::BigInt ||= Class.new(GraphQL::Schema::Scalar) do
          graphql_name 'BigInt'
          description 'WTF ??'

          def self.coerce_input(value, _ctx)
            begin
              value.to_i
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex)
            end
          end
        end

        Graphoid::Scalars::Decimal ||= Class.new(GraphQL::Schema::Scalar) do
          graphql_name 'Decimal'
          description 'Define pliiiizzzzzzz'
        end

        Graphoid::Scalars::Hash ||= Class.new(GraphQL::Schema::Scalar) do
          graphql_name 'Hash'
          description 'Hash scalar'

          def self.coerce_input(input_value, _ctx)
            input_value.to_h
          rescue StandardError
            raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid Hash"
          end

          def self.coerce_result(ruby_value, _ctx)
            binding.pry
            ruby_value.to_h
          end
        end

        Graphoid::Scalars::Array ||= Class.new(GraphQL::Schema::Scalar) do
          graphql_name 'Array'
          description 'Array scalar'
        end
      end
    end
  end
end

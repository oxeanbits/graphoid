# frozen_string_literal: true

module Graphoid
  module Upload
  end

  module Scalars
    class << self
      def generate
        Graphoid::Scalars::DateTime ||= GraphQL::ScalarType.define do
          name 'DateTime'
          description 'DateTime ISO8601 formated'

          coerce_input lambda { |value, _|
            begin
              ::DateTime.iso8601(value)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex)
            end
          }
        end

        Graphoid::Scalars::Date ||= GraphQL::ScalarType.define do
          name 'Date'
          description 'Date ISO8601 formated'

          coerce_input lambda { |value, _|
            begin
              ::DateTime.iso8601(value)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex)
            end
          }
        end

        Graphoid::Scalars::Time ||= GraphQL::ScalarType.define do
          name 'Time'
          description 'Time ISO8601 formated'

          coerce_input lambda { |value, _|
            begin
              ::DateTime.iso8601(value)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex)
            end
          }
        end

        Graphoid::Scalars::Timestamp ||= GraphQL::ScalarType.define do
          name 'Timestamp'
          description 'Second elapsed since 1970-01-01'

          coerce_input lambda { |value, _|
            begin
              ::DateTime.iso8601(value)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex)
            end
          }
        end

        Graphoid::Scalars::Text ||= GraphQL::ScalarType.define do
          name 'Text'
          description 'Should be string? explain this please.'
        end

        Graphoid::Scalars::BigInt ||= GraphQL::ScalarType.define do
          name 'BigInt'
          description 'WTF ??'
        end

        Graphoid::Scalars::Decimal ||= GraphQL::ScalarType.define do
          name 'Decimal'
          description 'Define pliiiizzzzzzz'
        end

        Graphoid::Scalars::Hash ||= GraphQL::ScalarType.define do
          name 'Hash'
          description 'Hash scalar'

          def self.coerce_input(input_value, _context)
            input_value.to_h
          rescue StandardError
            raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid Hash"
          end

          def self.coerce_result(ruby_value, _context)
            ruby_value.to_h
          end
        end

        Graphoid::Scalars::Array ||= GraphQL::ScalarType.define do
          name 'Array'
          description 'Array scalar'
        end
      end
    end
  end
end

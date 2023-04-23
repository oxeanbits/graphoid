# frozen_string_literal: true

module Graphoid
  module Queries
    module Processor
      class << self
        def execute(scope, object)
          object.each do |key, value|
            key = key.to_s if key.is_a? Symbol
            scope = process(scope, value, key)
          end
          scope
        end

        def execute_array(scope, list, action)
          if action == 'OR'
            scope = Graphoid.driver.execute_or(scope, list)
          else
            list.each { |object| scope = execute(scope, object) }
          end
          scope
        end

        def process(scope, value, key = nil)
          if key && %w[OR AND].exclude?(key)
            operation = Operation.new(scope, key, value)
            filter = operation.resolve
            return Graphoid.driver.execute_and(scope, filter)
          end

          if operation.nil? || operation.type == :attribute
            return execute(scope, value) if value.is_a?(Hash)
            if value.is_a?(Array) && %w[in nin].exclude?(operation&.operator)
              return execute_array(scope, value, key)
            end
          end
        end

        def parse_order(scope, order)
          fields = Attribute.fieldnames_of(scope)
          Utils.underscore(order, fields)
        end
      end
    end
  end
end


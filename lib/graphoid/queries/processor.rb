# frozen_string_literal: true

module Graphoid
  module Queries
    module Processor
      class << self
        def execute(scope, object = nil, context: nil, **object_keywords)
          context ||= ExecutionContext.new
          object ||= object_keywords

          object.each do |key, value|
            key = key.to_s if key.is_a? Symbol
            scope = process(scope, value, key, context: context)
          end
          scope
        end

        def execute_array(scope, list, action, context: nil)
          context ||= ExecutionContext.new

          if action == 'OR'
            scope = Graphoid.driver.execute_or(scope, list, context: context)
          else
            list.each { |object| scope = execute(scope, object, context: context) }
          end
          scope
        end

        def process(scope, value, key = nil, context: nil)
          context ||= ExecutionContext.new

          if key && %w[OR AND].exclude?(key)
            operation = Operation.new(scope, key, value, context: context)
            filter = operation.resolve
            return Graphoid.driver.execute_and(scope, filter)
          end

          if operation.nil? || operation.type == :attribute
            return execute(scope, value, context: context) if value.is_a?(Hash)
            if value.is_a?(Array) && %w[in nin].exclude?(operation&.operator)
              return execute_array(scope, value, key, context: context)
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

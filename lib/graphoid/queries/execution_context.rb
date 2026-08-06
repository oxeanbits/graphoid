# frozen_string_literal: true

module Graphoid
  module Queries
    class ExecutionContext
      def initialize(scope_provider = nil, &scope_provider_block)
        @scope_provider = scope_provider || scope_provider_block
      end

      def scope_for(model, relation:, parent_scope:)
        return model.all unless @scope_provider

        if @scope_provider.respond_to?(:scope_for)
          return @scope_provider.scope_for(model, relation: relation, parent_scope: parent_scope)
        end

        @scope_provider.call(model, relation: relation, parent_scope: parent_scope)
      end
    end
  end
end

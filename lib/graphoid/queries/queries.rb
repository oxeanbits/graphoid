# frozen_string_literal: true

module Graphoid
  module Queries
    def self.generate(*models)
      models.each { |model| Graphoid::Queries.build(model) }
    end

    def self.build(model)
      Graphoid.initialize
      grapho = Graphoid.build(model)
      query_type = ::Types::QueryType

      query_type.field name: grapho.name, type: grapho.type, null: true do
        argument :id, GraphQL::Types::ID, required: false
        argument :where, grapho.filter, required: false
      end

      query_type.field name: grapho.plural, type: [grapho.type], null: true do
        Graphoid::Argument.query_many(self, grapho.filter, grapho.order, required: false)
      end

      query_type.class_eval do
        # Dynamically defining a resolver method for queries:
        # query {
        # project(id: "5e7b5b9b0b0b0b0b0b0b0b0b", where: { name_regex: "[a-z]" }) {
        #  id
        #  name
        # }
        define_method :"#{grapho.name}" do |id: nil, where: nil|
          begin
            return model.find(id) if id
            Processor.execute(model, where.to_h).first
          rescue Exception => ex
            GraphQL::ExecutionError.new(ex.message)
          end
        end
      end

      query_type.class_eval do
        # Dynamically defining a resolver method for queries:
        # query {
        #  projects(where: { name_contains: "a" }, order: { name: ASC }, limit: 10, skip: 10) {
        #    id
        #    name
        # }
        define_method :"#{grapho.plural}" do |where: nil, order: nil, limit: nil, skip: nil|
          begin
            # irep_node is deprecated
            # maybe use context.ast_node instead
            # but the problem is that it is not the same
            # model = Graphoid.driver.eager_load(context.irep_node, model)
            # https://graphql-ruby.org/fields/introduction.html#extra-field-metadata
            result = Processor.execute(model, where.to_h)
            order = Processor.parse_order(model, order.to_h)
            result = result.order(order).limit(limit)
            Graphoid.driver.skip(result, skip)
          rescue Exception => ex
            GraphQL::ExecutionError.new(ex.message)
          end
        end
      end
    end
  end
end


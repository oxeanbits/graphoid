# frozen_string_literal: true

module Graphoid
  module Queries::Pagination
    PAGE_SIZE = (ENV['PAGE_SIZE'] || 100).to_i

    def self.generate(*models)
      models.each { |model| Graphoid::Queries::Pagination.build(model) }
    end

    def self.prepare_paginated_scope(model, scope, lookahead)
      return model.graphoid_prepare_paginated_scope(scope, lookahead: lookahead) if
        model.respond_to?(:graphoid_prepare_paginated_scope)
      return scope unless scope.respond_to?(:lookahead)

      scope.lookahead(scope, lookahead) || scope
    end

    def self.load_paginated_data(model, scope, lookahead)
      return model.graphoid_load_paginated_data(scope, lookahead: lookahead) if
        model.respond_to?(:graphoid_load_paginated_data)
      return scope.eager_load if scope.respond_to?(:eager_load)

      scope
    end

    def self.build(model)
      Graphoid.initialize
      grapho = Graphoid.build(model)
      query_type = ::Types::QueryType

      query_type.field name: grapho.name, type: grapho.type, null: true do
        argument :id, GraphQL::Types::ID, required: false
        argument :where, grapho.filter, required: false
      end

      paginated_type = Class.new(GraphQL::Schema::Object) do
        graphql_name("#{model.name}Pagination")
        description('Pagination Type')

        # https://www.rubydoc.info/github/rmosolgo/graphql-ruby/GraphQL/Field
        # Syntax => name, type, description
        field :count, GraphQL::Types::Int, null: true
        field :page_size, GraphQL::Types::Int, null: true
        field :pages, GraphQL::Types::Int, null: true
        field :skip, GraphQL::Types::Int, null: true
        field :data, [grapho.type], null: true, extras: [:lookahead]

        define_method(:data) do |lookahead:|
          scope = Graphoid::Queries::Pagination.prepare_paginated_scope(model, object, lookahead)
          Graphoid::Queries::Pagination.load_paginated_data(model, scope, lookahead)
        end

        def page_size
          return PAGE_SIZE if object.options[:limit].nil? or object.options[:limit] > PAGE_SIZE

          object.options[:limit]
        end

        def skip
          object.options[:skip] || 0
        end

        def pages
          return 1 if object.options[:limit].nil?

          (object.count / object.options[:limit].to_f).ceil
        end
      end

      query_type.field name: grapho.plural, type: paginated_type, null: true do
        argument :where, grapho.filter, required: false
        argument :order, grapho.order, required: false
        argument :limit, GraphQL::Types::Int, required: false, default_value: PAGE_SIZE,
          prepare: lambda { |limit, _ctx|
            limit = PAGE_SIZE if limit > PAGE_SIZE
            return limit
          }
        argument :skip,  GraphQL::Types::Int, required: false
      end

      Graphoid::Queries.define_resolvers(query_type, model, grapho.name, grapho)
    end
  end
end

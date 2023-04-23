# frozen_string_literal: true

module Graphoid
  module Queries::Pagination
    PAGE_SIZE = (ENV['PAGE_SIZE'] || 100).to_i

    def self.generate(*models)
      models.each { |model| Graphoid::Queries::Pagination.build(model) }
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

        #field :pageSize, !GraphQL::Types::Int, I18n.t('pagination.page_size_hint') do
        #  resolve lambda { |obj, _args, _ctx|
        #    return PAGE_SIZE if obj.options[:limit].nil? or obj.options[:limit] > PAGE_SIZE

        #    obj.options[:limit]
        #  }
        #end

        #field :pages, !types.Int, I18n.t('pagination.pages_hint') do
        #  resolve lambda { |obj, _args, _ctx|
        #    return 1 if obj.options[:limit].nil?

        #    (obj.count / obj.options[:limit]) + 1
        #  }
        #end

        #field :skip, !types.Int, I18n.t('pagination.skip_hint') do
        #  resolve ->(obj, _args, _ctx) { obj.options[:skip] || 0 }
        #end

        field :data, [grapho.type], null: true

        def data
          return object.eager_load if object.respond_to? :eager_load
          object
        end
      end

      #query_type.field name: grapho.plural, type: [grapho.type], null: true do
      #  Graphoid::Argument.query_many(self, grapho.filter, grapho.order, required: false)
      #end

      #query_type.class_eval do
      #  # Dynamically defining a resolver method for queries:
      #  # query {
      #  # project(id: "5e7b5b9b0b0b0b0b0b0b0b0b", where: { name_regex: "[a-z]" }) {
      #  #  id
      #  #  name
      #  # }
      #  define_method :"#{grapho.name}" do |id: nil, where: nil|
      #    begin
      #      return model.find(id) if id
      #      Processor.execute(model, where.to_h).first
      #    rescue Exception => ex
      #      GraphQL::ExecutionError.new(ex.message)
      #    end
      #  end
      #end

      #query_type.class_eval do
      #  # Dynamically defining a resolver method for queries:
      #  # query {
      #  #  projects(where: { name_contains: "a" }, order: { name: ASC }, limit: 10, skip: 10) {
      #  #    id
      #  #    name
      #  # }
      #  define_method :"#{grapho.plural}" do |where: nil, order: nil, limit: nil, skip: nil|
      #    begin
      #      # irep_node is deprecated
      #      # maybe use context.ast_node instead
      #      # but the problem is that it is not the same
      #      # model = Graphoid.driver.eager_load(context.irep_node, model)
      #      # https://graphql-ruby.org/fields/introduction.html#extra-field-metadata
      #      result = Processor.execute(model, where.to_h)
      #      order = Processor.parse_order(model, order.to_h)
      #      result = result.order(order).limit(limit)
      #      Graphoid.driver.skip(result, skip)
      #    rescue Exception => ex
      #      GraphQL::ExecutionError.new(ex.message)
      #    end
      #  end
      #end

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
            Graphoid::Queries::Processor.execute(model, where.to_h).first
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
            result = Graphoid::Queries::Processor.execute(model, where.to_h)
            order = Graphoid::Queries::Processor.parse_order(model, order.to_h)
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

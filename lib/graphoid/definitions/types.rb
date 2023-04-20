module Graphoid
  module Resolvers
    def self.resolver_class(relation_class, relation_type, association)
      association_name = association.name
      relation_name = Utils.graphqlize(relation_class.name)

      Class.new(GraphQL::Schema::Resolver) do
        type [relation_type], null: true

        self.const_set(:ASSOCIATION_NAME, association_name)

        filter = Graphoid::Filters::LIST[relation_class]
        filter = "Graphoid::Types::#{relation_name}Filter" unless filter
        order  = Graphoid::Sorter::LIST[relation_class]
        order = "Graphoid::Types::#{relation_name}Sorter" unless order

        argument :where, filter, required: false
        argument :order, order, required: false
        argument :limit, GraphQL::Types::Int, required: false
        argument :skip,  GraphQL::Types::Int, required: false

        def resolve(where: nil, order: nil, limit: nil, skip: nil)
          obj = self.object
          processor = Graphoid::Queries::Processor

          association_name = self.class.const_get(:ASSOCIATION_NAME)
          result = obj.send(association_name)
          result = processor.execute(result, where) if where.present?

          if order.present?
            order = processor.parse_order(obj.send(association_name), order)
            result = result.order(order)
          end

          result = result.limit(limit) if limit.present?
          result = result.skip(skip) if skip.present?

          result
        end
      end
    end
  end

  module Types
    LIST = {}
    ENUMS = {}

    class << self
      def initialize(*models)
        models.each do |model|
          type_const = "#{model.name}Type"
          filter_const = "#{model.name}Filter"
          sorter_const = "#{model.name}Sorter"
          Graphoid::Types::const_set(type_const, Class.new(GraphQL::Schema::Object))
          Graphoid::Types::const_set(filter_const, Class.new(GraphQL::Schema::InputObject))
          Graphoid::Types::const_set(sorter_const, Class.new(GraphQL::Schema::InputObject))
        end
      end

      def generate(model)
        unless LIST[model]
          model_type_const = "Graphoid::Types::#{Utils.graphqlize(model.name)}Type"
          LIST[model] ||= Graphoid::Types.const_get(model_type_const)

          LIST[model].class_eval do
            name = Utils.graphqlize(model.name)
            graphql_name("#{name}Type")
            description("Generated model type for #{name}")

            Attribute.fields_of(model).each do |attribute|
              type = Graphoid::Mapper.convert(attribute)
              name = Utils.camelize(attribute.name)
              field(name, type)

              model.class_eval do
                if attribute.name.include?('_')
                  define_method :"#{Utils.camelize(attribute.name)}" do
                    method_name = attribute.name.to_s
                    self[method_name] || send(method_name)
                  end
                end
              end
            end

            Relation.relations_of(model).each do |_, relation|
              relation_class = relation.class_name.safe_constantize
              relation_name = Utils.graphqlize(relation_class.name)

              message = "in model #{model.name}: skipping relation #{relation.class_name}"
              unless relation_class
                warn "Graphoid: warning: #{message} because the model name is not valid" if ENV['DEBUG']
                next
              end

              relation_type = LIST[relation_class]
              unless relation_type
                # using string type to avoid circular dependency
                # https://github.com/rmosolgo/graphql-ruby/issues/2874#issuecomment-614104142
                relation_type = "Graphoid::Types::#{relation_name}Type"
              end

              name = Utils.camelize(relation.name)

              model.class_eval do
                if relation.name.to_s.include?('_')
                  define_method :"#{name}" do
                    send(relation.name)
                  end
                end
              end

              next unless relation_type

              filter = Graphoid::Filters::LIST[relation_class]
              filter = "Graphoid::Types::#{relation_name}Filter" unless filter

              if Relation.new(relation).many?
                plural_name = name.pluralize

                resolver = Graphoid::Resolvers.resolver_class(relation_class, relation_type, relation)
                field plural_name, resolver: resolver
              else
                # one-to-one relation
                field name, relation_type
              end
            end
          end
          LIST[model]
        end
      end
    end
  end
end

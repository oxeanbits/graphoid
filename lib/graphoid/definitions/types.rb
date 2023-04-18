require 'graphoid/operators/attribute'
require 'graphoid/operators/relation'
require 'graphoid/mapper'
require 'graphoid/queries/processor'

module Graphoid
  module Resolvers
    def self.resolver_class(relation_class, relation_type, association)
      association_name = association.name || "casa"
      relation_name = Utils.graphqlize(relation_class.name)

      Class.new(GraphQL::Schema::Resolver) do
        type [relation_type], null: true

        filter = Graphoid::Filters::LIST[relation_class]
        filter = "Graphoid::Types::#{relation_name}Filter" unless filter
        order  = Graphoid::Sorter::LIST[relation_class]
        order = "Graphoid::Types::#{relation_name}Sorter" unless order
        puts "resolver_class: #{relation_class}, #{relation_type}, #{association}"
        @@association_name = association_name

        argument :where, filter, required: false
        argument :order, order, required: false
        argument :limit, GraphQL::Types::Int, required: false
        argument :skip,  GraphQL::Types::Int, required: false

        def resolve(where: nil, order: nil, limit: nil, skip: nil)
          obj = self.object
          processor = Graphoid::Queries::Processor

          result = obj.send(@@association_name)
          result = processor.execute(result, where) if where.present?

          if order.present?
            order = processor.parse_order(obj.send(@@association_name), order)
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
      def generate(model)
        Graphoid::Types::Meta ||= Class.new(GraphQL::Schema::Object) do
          graphql_name('xMeta')
          description('xMeta Type')
          #field('count', types.Int)
          field('count', GraphQL::Types::Int)
        end


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
                relation_type = "Graphoid::Types::#{relation_name}Type"
                #warn "Graphoid: warning: #{message} because it was not found as a model" if ENV['DEBUG']
                #next
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

                #field "x_meta_#{plural_name}", Graphoid::Types::Meta do
                #  Graphoid::Argument.query_many(self, filter, order, required: false)
                #  Graphoid::Types.resolve_many(self, relation_class, relation)
                #end
              else
                field name, relation_type do
                  argument :where, filter, required: false
                  #Graphoid::Types.resolve_one(self, relation_class, relation)
                end
              end
            end
          end
          LIST[model]
        end
      end

      #def resolve_one(field, model, association)
      #  #field.resolve lambda { |obj, args, _ctx|
      #  #  filter = args['where'].to_h
      #  #  result = obj.send(association.name)
      #  #  processor = Graphoid::Queries::Processor
      #  #  if filter.present? && result
      #  #    result = processor.execute(model.where(id: result.id), filter).first
      #  #  end
      #  #  result
      #  #}
      #end

      def resolve_many(field, _model, association)
        #field.resolve lambda { |obj, args, _ctx|
        #  filter = args['where'].to_h
        #  order = args['order'].to_h
        #  limit = args['limit']
        #  skip = args['skip']

        #  processor = Graphoid::Queries::Processor

        #  result = obj.send(association.name)
        #  result = processor.execute(result, filter) if filter.present?

        #  if order.present?
        #    order = processor.parse_order(obj.send(association.name), order)
        #    result = result.order(order)
        #  end

        #  result = result.limit(limit) if limit.present?
        #  result = result.skip(skip) if skip.present?

        #  result
        #}
      end
    end
  end
end


# frozen_string_literal: true

module Graphoid
  module Sorter
    LIST = {}
    @@enum_type = nil
    @@dynamic_type = nil

    class << self
      def generate(model)
        unless LIST[model]
          model_type_const = "Graphoid::Types::#{Utils.graphqlize(model.name)}Sorter"
          LIST[model] ||= Graphoid::Types.const_get(model_type_const)

          LIST[model].class_eval do
            graphql_name("#{Utils.graphqlize(model.name)}Sorter")
            description("Generated model Sorter for #{model.name}")

            Attribute.fields_of(model).each do |field|
              name = Utils.camelize(field.name)
              next argument(name, Sorter.dynamic_type, required: false) if field.try(:dynamic?)
              argument(name, Sorter.enum_type, required: false)
            end

            #Relation.relations_of(model).each do |name, relation|
            #  relation_class = relation.class_name.safe_constantize
            #  next unless relation_class

            #  relation_order = LIST[relation_class]
            #  next unless relation_order

            #  relation_name = Utils.camelize(name)

            #  argument(relation_name, relation_order)
            #end
          end
        end

        LIST[model]
      end

      def enum_type
        @@enum_type ||= Class.new(GraphQL::Schema::Enum) do
          graphql_name 'SorterType'

          value 'ASC', 'Ascendent'
          value 'DESC', 'Descendent'
        end
      end

      def dynamic_type
        @@dynamic_type ||= Graphoid::Scalars::Hash
      end
    end
  end
end

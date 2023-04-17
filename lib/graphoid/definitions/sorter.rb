module Graphoid
  module Sorter
    LIST = {}
    @@enum_type = nil
    @@dynamic_type = nil

    class << self
      def generate(model)
        LIST[model] ||= Class.new(GraphQL::Schema::InputObject) do
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

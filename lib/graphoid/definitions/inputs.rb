module Graphoid
  module Inputs
    LIST = {}

    class << self
      def generate(model)
        LIST[model] ||= Class.new(GraphQL::Schema::InputObject) do
          name = Utils.graphqlize(model.name)
          graphql_name("#{name}Input")
          description("Generated model input for #{name}")

          Attribute.fields_of(model).each do |field|
            next if field.name.start_with?('_')

            type = Graphoid::Mapper.convert(field)
            name = Utils.camelize(field.name)

            argument(name, type, required: false)
          end

          Relation.relations_of(model).each do |name, relation|
            relation_class = relation.class_name.safe_constantize
            next unless relation_class

            relation_input = LIST[relation_class]
            next unless relation_input

            name = Utils.camelize(relation.name)

            r = Relation.new(relation)
            if r.many?
              argument(name, -> { [relation_input] }, required: false)
            else
              argument(name, -> { relation_input }, required: false)
            end
          end
        end
      end

      #def generate(model)
      #  model_type_const = "Graphoid::Types::#{Utils.graphqlize(model.name)}Input"
      #  LIST[model] ||= Graphoid::Types.const_get(model_type_const)

      #  LIST[model].class_eval do
      #    name = Utils.graphqlize(model.name)
      #    graphql_name("#{name}Input")
      #    description("Generated model input for #{name}")

      #    Attribute.fields_of(model).each do |field|
      #      next if field.name.start_with?('_')

      #      type = Graphoid::Mapper.convert(field)
      #      name = Utils.camelize(field.name)

      #      argument(name, type, required: false)
      #    end

      #    #Relation.relations_of(model).each do |name, relation|
      #    #  relation_class = relation.class_name.safe_constantize
      #    #  relation_name = Utils.graphqlize(relation_class.name)
      #    #  next unless relation_class

      #    #  relation_input = LIST[relation_class]
      #    #  relation_input = "Graphoid::Types::#{relation_name}Input" unless relation_input

      #    #  name = Utils.camelize(relation.name)

      #    #  r = Relation.new(relation)
      #    #  if r.many?
      #    #    # argument(name, -> { [relation_input] })
      #    #    puts "relation: #{relation.name}"
      #    #  else
      #    #    # argument(name, -> { relation_input })
      #    #    puts "relation: #{relation.name}"
      #    #  end
      #    #end
      #  end
      #end
    end
  end
end

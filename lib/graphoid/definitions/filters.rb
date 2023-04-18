require 'graphoid/operators/relation'

module Graphoid
  module Filters
    LIST = {}

    class << self
      def generate(model)
        unless LIST[model]
          model_type_const = "Graphoid::Types::#{Utils.graphqlize(model.name)}Filter"
          LIST[model] ||= Graphoid::Types.const_get(model_type_const)

          LIST[model].class_eval do
            graphql_name("#{Utils.graphqlize(model.name)}Filter")
            description("Generated model filter for #{model.name}")

            m = self
            argument(:OR,  -> { [m] }, required: false)
            argument(:AND, -> { [m] }, required: false)

            Attribute.fields_of(model).each do |field|
              type = Graphoid::Mapper.convert(field)
              name = Utils.camelize(field.name)

              argument name, type, required: false

              # m = LIST[model]
              # argument(:OR,  m, required: false)
              # argument(:OR,  -> { m }, required: false)

              operators = %w[lt lte gt gte contains not]
              operators.push('regex') if Graphoid.configuration.driver == :mongoid

              operators.each do |suffix|
                argument "#{name}_#{suffix}", type, required: false
              end

              %w[in nin].each do |suffix|
                argument "#{name}_#{suffix}", [type], required: false
              end
            end

            Relation.relations_of(model).each do |name, relation|
              relation_class = relation.class_name.safe_constantize
              relation_name = Utils.graphqlize(relation_class.name)

              next unless relation_class

              relation_filter = LIST[relation_class]
              relation_filter = "Graphoid::Types::#{relation_name}Filter" unless relation_filter

              relation_name = Utils.camelize(name)

              if Relation.new(relation).many?
                %w[some none every].each do |suffix|
                  argument "#{relation_name}_#{suffix}", relation_filter, required: false
                end
              else
                argument relation_name.to_s, relation_filter, required: false
              end
            end
          end
        end
        LIST[model]
      end
    end
  end
end

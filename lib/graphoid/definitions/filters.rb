# frozen_string_literal: true

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

              argument name, type, required: false, camelize: false

              # m = LIST[model]
              # argument(:OR,  m, required: false)
              # argument(:OR,  -> { m }, required: false)

              operators = %w[lt lte gt gte contains not]
              operators.push('regex') if Graphoid.configuration.driver == :mongoid

              operators.each do |suffix|
                argument "#{name}_#{suffix}", type, required: false, camelize: false
              end

              %w[in nin].each do |suffix|
                argument "#{name}_#{suffix}", [type], required: false, camelize: false
              end
            end

          end
        end
        LIST[model]
      end
    end
  end
end

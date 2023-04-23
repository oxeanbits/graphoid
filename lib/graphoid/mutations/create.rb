# frozen_string_literal: true

module Graphoid
  module Mutations
    module Create
      def self.build(model)
        Graphoid.initialize
        grapho = Graphoid.build(model)
        type = ::Types::MutationType

        name = "create_#{grapho.name}"
        plural_name = name.pluralize

        type.field(name: name, type: grapho.type, null: true) do
          argument(:data, grapho.input, required: false)
        end

        type.class_eval do
          define_method :"#{name}" do |data: {}|
            begin
              user = context[:current_user]
              Graphoid::Mutations::Processor.execute(model, grapho, data, user)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex.message)
            end
          end
        end
      end
    end
  end
end

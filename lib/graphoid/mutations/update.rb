# frozen_string_literal: true

module Graphoid
  module Mutations
    module Update
      extend ActiveSupport::Concern

      def self.build(model)
        Graphoid.initialize
        grapho = Graphoid.build(model)
        type = ::Types::MutationType

        name = "update_#{grapho.name}"
        plural = "update_many_#{grapho.plural}"

        type.field name: name, type: grapho.type, null: true do
          argument :id, GraphQL::Types::ID, required: true
          argument :data, grapho.input, required: false
        end

        type.class_eval do
          define_method :"#{name}" do |id:, data: {}|
            attrs = Utils.build_update_attributes(data, model, context)

            begin
              object = model.find(id)
              object.update!(attrs)
              object.reload
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex.message)
            end
          end
        end
      end
    end
  end
end

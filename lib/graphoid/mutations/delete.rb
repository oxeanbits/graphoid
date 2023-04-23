# frozen_string_literal: true

module Graphoid
  module Mutations
    module Delete
      extend ActiveSupport::Concern

      def self.build(model)
        Graphoid.initialize
        grapho = Graphoid.build(model)
        type = ::Types::MutationType

        name = "delete_#{grapho.name}"
        plural = "delete_many_#{grapho.plural}"

        type.field(name: name, type: grapho.type, null: true) do
          argument :id, GraphQL::Types::ID, required: true
        end

        type.class_eval do
          define_method :"#{name}" do |id:|
            begin
              result = model.find(id)
              result.destroy!
              result
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex.message)
            end
          end
        end
      end
    end
  end
end

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

        type.field(name: plural, type: [grapho.type], null: true) do
          argument :where, grapho.filter, required: false
        end

        type.class_eval do
          define_method :"#{name}" do |id:|
            begin
              result = if model.respond_to?(:resolve_find_before_delete)
                         model.resolve_find_before_delete(self, id)
                       else
                         model.find(id)
                       end
              result.destroy!
              result
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex.message)
            end
          end
        end

        type.class_eval do
          define_method :"#{plural}" do |where: {}|
            begin
              objects = Graphoid::Queries::Processor.execute(model, where.to_h)
              objects = model.resolve_filter(self, objects) if model.respond_to?(:resolve_filter)
              objects.destroy_all
              objects.all.to_a
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex.message)
            end
          end
        end
      end
    end
  end
end

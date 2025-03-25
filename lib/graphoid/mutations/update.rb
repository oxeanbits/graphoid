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

        type.field name: plural, type: [grapho.type], null: true do
          argument :where, grapho.filter, required: false
          argument :data, grapho.input, required: false
        end

        type.class_eval do
          define_method :"#{name}" do |id:, data: {}|
            attrs = Utils.build_update_attributes(data, model, context)

            begin
              object = if model.respond_to?(:resolve_find_before_update)
                         model.resolve_find_before_update(self, id)
                       else
                         model.find(id)
                       end
              object.update!(attrs)
              object.reload
            rescue Exception => ex
              Utils.log_error(name, ex)
              GraphQL::ExecutionError.new(ex.message)
            end
          end
        end

        type.class_eval do
          define_method :"#{plural}" do |where: {}, data: {}|
            attrs = Utils.build_update_attributes(data, model, context)

            begin
              objects = Graphoid::Queries::Processor.execute(model, where.to_h)
              objects = model.resolve_filter(self, objects) if model.respond_to?(:resolve_filter)
              objects.update_all(attrs)
              objects.all.to_a
            rescue Exception => ex
              Utils.log_error(plural, ex)
              GraphQL::ExecutionError.new(ex.message)
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Graphoid
  module Mutations
    module CreateOrUpdate
      def self.build(model)
        Graphoid.initialize
        grapho = Graphoid.build(model)
        type = ::Types::MutationType

        name = "create_or_update_#{grapho.name}"
        plural_name = name.pluralize

        type.field(name: name, type: grapho.type, null: true) do
          argument :where, grapho.filter, required: true
          argument :data, grapho.input, required: true
        end

        type.class_eval do
          define_method :"#{name}" do |where: {}, data: {}|
            begin
              user = context[:current_user]

              object = if model.respond_to?(:resolve_one)
                          model.resolve_one(self, nil, where.to_h)
                        else
                          model.where(where.to_h).first
                        end

              if object
                attrs = Utils.build_update_attributes(data, model, context)
                object.update!(attrs)
                return object.reload
              end

              data = model.before_resolve_create(self, data) if model.respond_to?(:before_resolve_create)
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

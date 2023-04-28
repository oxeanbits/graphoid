# frozen_string_literal: true

module Graphoid
  module Utils
    class << self
      def modelize(text)
        graphqlize text.to_s.capitalize.camelize
      end

      def camelize(text)
        # we are doing it twice because _id gets translated to Id the first time and to id the second time.
        graphqlize text.to_s.camelize(:lower).camelize(:lower)
      end

      def graphqlize(text)
        text.to_s.gsub(/::/, '_')
      end

      def symbolize(fields)
        fields.keys.map { |f| f.underscore.to_sym  }
      end

      def children_of(selection)
        selection.scoped_children.values.first
      end

      def first_children_of(selection)
        selection.scoped_children.values.first.values.first.scoped_children.values.first
      end

      def underscore(props, fields = [])
        attrs = {}
        props.each do |key, value|
          key = key.to_s if key.is_a? Symbol
          key = key.camelize(:lower) if fields.exclude?(key)
          key = key.underscore if fields.exclude?(key)
          # embeds many is passing on update action an array of dynamic object like hash
          if value.is_a? Array
            value = value.map do |v|
              transformed = v
              transformed = v.to_h if v.respond_to?(:to_h)
              transformed
            end
          end

          if value.is_a? GraphQL::Schema::InputObject
            value = value.to_h
          end
          attrs[key] = value
        end
        attrs
      end

      def build_update_attributes(data, model, context)
        user = context[:current_user]
        fields = Graphoid::Attribute.fieldnames_of(model)
        attrs = underscore(data, fields)
        attrs['updated_by_id'] = user.id if user && fields.include?('updated_by_id')
        attrs
      end
    end
  end
end

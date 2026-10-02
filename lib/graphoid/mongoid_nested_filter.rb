# frozen_string_literal: true

module Graphoid
  module MongoidNestedFilter
    private

    def define_association!(macro_name, name, options = {}, &block)
      options = options.dup
      nested_filter = options.delete(:graphoid_nested_filter)
      association = super

      # Mongoid validates association options before Graphoid can inspect the reflection.
      association.options[:graphoid_nested_filter] = nested_filter if nested_filter
      association
    end
  end
end

Mongoid::Association::Macros::ClassMethods.prepend(Graphoid::MongoidNestedFilter)

require 'graphoid/operators/relation'
require 'graphoid/operators/attribute'

module Graphoid
  class HasMany < Relation
    def create(parent, values, grapho)
      values.each do |value|
        attributes = Attribute.correct(klass, value)
        attributes[:"#{grapho.name}_id"] = parent.id
        klass.create!(attributes)
      end
    end
  end
end

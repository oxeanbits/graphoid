# frozen_string_literal: true

module Graphoid
  class HasOne < Relation
    def create(parent, value, grapho)
      attributes = Attribute.correct(klass, value)
      attributes[:"#{grapho.name}_id"] = parent.id
      klass.create!(attributes)
    end
  end
end

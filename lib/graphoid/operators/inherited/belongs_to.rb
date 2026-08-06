# frozen_string_literal: true

module Graphoid
  class BelongsTo < Relation
    def precreate(value)
      sanitized = Attribute.correct(klass, value)
      foreign_id = klass.create!(sanitized).id
      { :"#{name}_id" => foreign_id }
    end
  end
end

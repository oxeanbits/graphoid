# frozen_string_literal: true

class ValueNested
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String
  field :name, type: String

  embedded_in :value
end

# frozen_string_literal: true

class Value
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String
  field :name, type: String

  embeds_many :value_nested
  embedded_in :account
end

# frozen_string_literal: true

class Snake
  include Mongoid::Document
  include Mongoid::Timestamps

  field :snake_case, type: Float
  field :camelCase, type: Integer
  field :name, type: String

  embedded_in :account
end

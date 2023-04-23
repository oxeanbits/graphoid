# frozen_string_literal: true

class Person
  include Mongoid::Document
  include Mongoid::Timestamps

  field :snake_case, type: String
  field :camelCase, type: String
  field :name, type: String

  belongs_to :account
end

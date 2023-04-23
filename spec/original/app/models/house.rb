# frozen_string_literal: true

class House
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_many :accounts, dependent: :destroy
end

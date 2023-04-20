# frozen_string_literal: true

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_and_belongs_to_many :dependencies, class_name: 'User', inverse_of: :dependents
  has_and_belongs_to_many :dependents, class_name: 'User', inverse_of: :dependencies

  has_and_belongs_to_many :accounts, inverse_of: :users
end

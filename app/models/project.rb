require 'graphoid/queries/queries'

class Project < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include Graphoid::Queries

  field :id, type: String
  field :name, type: String
  field :active, type: Boolean, default: true

  validates :name, presence: true
  validates :id, presence: true
  validates :active, presence: true
end

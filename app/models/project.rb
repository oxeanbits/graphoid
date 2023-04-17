require 'graphoid/queries/queries'

class Project < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps

  #field :id, type: String # crashing due to duplicated field
  field :name, type: String
  field :active, type: Boolean, default: true

  include Graphoid::Queries

  validates :name, presence: true
  validates :id, presence: true
  validates :active, presence: true
end

# frozen_string_literal: true

class Label < ApplicationRecord
  include Graphoid::Queries
  include Graphoid::Mutations
  include Graphoid::Graphield

  belongs_to :account
end

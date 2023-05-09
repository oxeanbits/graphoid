# frozen_string_literal: true

class Level
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
end

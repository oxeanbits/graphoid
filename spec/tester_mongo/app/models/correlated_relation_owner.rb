# frozen_string_literal: true

class CorrelatedRelationOwner
  include Mongoid::Document

  field :code, type: String
  field :tenant, type: String
  field :name, type: String
end

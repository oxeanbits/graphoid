# frozen_string_literal: true

class CorrelatedRelationProfile
  include Mongoid::Document

  field :parent_lookup, type: String
  field :tenant, type: String
  field :status, type: String
end

# frozen_string_literal: true

class CorrelatedRelationChild
  include Mongoid::Document

  field :parent_lookup, type: String
  field :reviewer_code, type: String
  field :tenant, type: String
  field :status, type: String

  belongs_to :reviewer,
             class_name: 'CorrelatedRelationOwner',
             foreign_key: 'reviewer_code',
             primary_key: 'code',
             optional: true
end

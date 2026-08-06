# frozen_string_literal: true

class CorrelatedRelationParent
  include Mongoid::Document

  field :lookup, type: String
  field :owner_code, type: String
  field :tenant, type: String
  field :name, type: String

  belongs_to :owner,
             class_name: 'CorrelatedRelationOwner',
             foreign_key: 'owner_code',
             primary_key: 'code',
             optional: true

  has_one :profile,
          class_name: 'CorrelatedRelationProfile',
          foreign_key: 'parent_lookup',
          primary_key: 'lookup'

  has_many :children,
           class_name: 'CorrelatedRelationChild',
           foreign_key: 'parent_lookup',
           primary_key: 'lookup'
end

# frozen_string_literal: true

class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  include Graphoid::Graphield

  graphield :graphield0, String
  graphield :graph_field_1, String
  graphield :graphField2, Integer

  graphorbid :forbidden
  field :forbidden, type: Integer

  field :integer_field, type: Integer
  field :float_field, type: Float
  field :string_field, type: String

  field :snake_case, type: String
  field :camelCase, type: String

  field :datetime_field, type: DateTime

  field :array, type: Array
  field :object, type: Hash

  def graphield0
    string_field.to_s + ' custom 0'
  end

  def graph_field_1
    string_field.to_s + ' custom 1'
  end

  def graphField2
    integer_field.to_i + 10
  end

  has_and_belongs_to_many :users

  has_one :person
  has_many :labels
  belongs_to :house, optional: true

  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  embeds_one :value
  embeds_many :snakes

  def self.before_resolve_create(model, data)
    if data[:string_field] == 'hook'
      data = data.to_h
      data[:string_field] = 'hook_changed'
      return data
    end

    data
  end

  def self.resolve_find_before_update(resolver, id)
    where.not(string_field: 'hook').find(id)
  end

  def self.resolve_find_before_delete(resolver, id)
    where.not(string_field: 'hook').find(id)
  end

  def self.resolve_one(resolver, id, filter)
    result = where.not(string_field: 'hook')
    result = Graphoid::Queries::Processor.execute(result, filter.to_h)
    return result.find(id) if id
    result.first
  end
end

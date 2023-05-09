# frozen_string_literal: true

class Player
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :active, type: Boolean, default: true

  def self.resolve_many(resolver, where_args, order, limit, skip)
    w = where_args.to_h
    w[:active] = true
    result = Graphoid::Queries::Processor.execute(self, w)
    order = Graphoid::Queries::Processor.parse_order(self, order.to_h)
    result = result.order(order).limit(limit)
    Graphoid.driver.skip(result, skip)
  end
end

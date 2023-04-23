module MongoidExtensions
  extend ActiveSupport::Concern

  DELTA = 0.00001

  module ClassMethods
    # Get the element at the desired index
    # Usage: Model.get(index)
    def get(index)
      return if index < 1

      asc('_id').offset(index - 1).first
    end

    # Get the first element that matches opts
    # Usage: Model.get_by(column: value)
    def get_by(opts)
      where(opts).first
    end

    # Get the median value of attr
    # Usage: Model.where(active: true).median('age')
    def median(attr)
      return if empty?

      sorted = order_by(attr => :asc)
      index = (sorted.count - 1) / 2.0
      middle = sorted.skip(index.floor)
      return unless middle[0].respond_to? attr

      return middle[0].send(attr) if sorted.count.odd?

      (middle[0].send(attr) + middle[1].send(attr)) / 2.0
    end

    # Perform where by DELTA (for numeric comparisons)
    # Usage: Model.where_delta(temperature: 18.412421)
    def where_delta(opts)
      key, value = opts.first.flatten
      where(key.to_sym.gt => (value - DELTA), key.to_sym.lt => (value + DELTA))
    end
  end
end

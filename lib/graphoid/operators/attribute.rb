# frozen_string_literal: true

module Graphoid
  class Attribute
    attr_reader :name, :type, :opts

    PERMS = %i[read create update delete]

    def initialize(name:, type:, opts: {})
      @name = name.to_s
      @camel_name = Utils.camelize(@name)
      @type = type
      @opts = opts
    end

    def dynamic?
      @opts[:dynamic] == true
    end

    def resolve(o)
      Graphoid.driver.parse(o.operand, o.value, o.operator)
    end

    def embedded?
      false
    end

    def relation?
      false
    end

    def precreate(value)
      { name.to_sym => value }
    end

    def create(_, _, _); end

    class << self
      def fields_of(model, action = :read)
        fields = Graphoid.driver.fields_of(model) + graphields_of(model)
        fields.select { |field| forbidden_fields_of(model, action).exclude?(field.name) }
      end

      def fieldnames_of(model, action = :read)
        fields_of(model, action).map(&:name)
      end

      def graphields_of(model)
        model.respond_to?(:graphields) ? model.send(:graphields) : []
      end

      def forbidden_fields_of(model, action)
        skips = model.respond_to?(:forbidden_fields) ? model.send(:forbidden_fields) : []
        skips.map do |field, actions|
          field.to_s if actions.empty? || actions.include?(action)
        end
      end

      def correct(model, attributes)
        result = {}
        fieldnames = fieldnames_of(model)
        attributes.each do |key, value|
          key = key.to_s.camelize(:lower) if fieldnames.exclude?(key)
          key = key.to_s.underscore if fieldnames.exclude?(key.to_s)
          result[key] = value
        end
        result
      end
    end
  end
end

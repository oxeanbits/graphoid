module Graphoid
  class Operation
    attr_reader :scope, :operand, :operator, :value

    def initialize(scope, key, value, camelize: false)
      # camelize it because graphql 2.0 is passing keys as symbols using underscore format
      # but for queries we need the underscore format to identify operators such as contains, regex
      key = key.to_s.camelcase(:lower) if camelize
      @scope = scope
      @operator = nil
      @operand = key
      @value = value

      match = key.match(/^(.+)_(lt|lte|gt|gte|contains|not|in|nin|regex)$/)
      @operand, @operator = match[1..2] if match
      @operand = build_operand(@scope, @operand) || @operand
    end

    def resolve
      @operand.resolve(self)
    end

    private

    def build_operand(model, key)
      key = key.to_s if key.is_a? Symbol
      key = '_id' if key == 'id'
      fields = Attribute.fields_of(model)

      field = fields.find { |f| f.name == key }
      return Attribute.new(name: key, type: field.type) if field

      field = fields.find { |f| f.name == key.underscore }
      return Attribute.new(name: key.underscore, type: field.type) if field

      field = fields.find { |f| f.name == key.camelize(:lower) }
      return Attribute.new(name: key.camelize(:lower), type: field.type) if field

      relations = model.reflect_on_all_associations

      relation = relations.find { |r| r.name == key.to_sym }
      return Graphoid.driver.class_of(relation).new(relation) if relation

      relation = relations.find { |r| r.name == key.underscore.to_sym }
      return Graphoid.driver.class_of(relation).new(relation) if relation
    end
  end
end


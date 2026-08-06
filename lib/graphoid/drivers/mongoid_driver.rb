# frozen_string_literal: true

module Graphoid
  # module that helps executing mongoid specific code
  module MongoidDriver
    class << self
      def through?(_type)
        false
      end

      def mongo_constants
        begin
          {
            many_to_many: Mongoid::Relations::Referenced::ManyToMany,
            has_many:     Mongoid::Relations::Referenced::Many,
            belongs_to:   Mongoid::Relations::Referenced::In,
            has_one:      Mongoid::Relations::Referenced::One,
            embeds_one:   Mongoid::Relations::Embedded::One,
            embeds_many:  Mongoid::Relations::Embedded::Many,
            embedded_in:  Mongoid::Relations::Embedded::In
          }
        rescue
          {
            many_to_many: Mongoid::Association::Referenced::HasAndBelongsToMany::Proxy,
            has_many:     Mongoid::Association::Referenced::HasMany::Proxy,
            belongs_to:   Mongoid::Association::Referenced::BelongsTo::Proxy,
            has_one:      Mongoid::Association::Referenced::HasOne::Proxy,
            embeds_one:   Mongoid::Association::Embedded::EmbedsOne::Proxy,
            embeds_many:  Mongoid::Association::Embedded::EmbedsMany::Proxy,
            embedded_in:  Mongoid::Association::Embedded::EmbeddedIn::Proxy
          }
        end
      end

      def has_and_belongs_to_many?(type)
        type == mongo_constants[:many_to_many]
      end

      def has_many?(type)
        type == mongo_constants[:has_many]
      end

      def belongs_to?(type)
        type == mongo_constants[:belongs_to]

      end

      def has_one?(type)
        type == mongo_constants[:has_one]
      end

      def embeds_one?(type)
        type == mongo_constants[:embeds_one]
      end

      def embeds_many?(type)
        type == mongo_constants[:embeds_many]
      end

      def embedded_in?(type)
        type == mongo_constants[:embedded_in]
      end

      def types_map
        {
          BSON::ObjectId => GraphQL::Types::ID,
          Mongoid::Boolean => GraphQL::Types::Boolean,
          # Graphoid::Upload => ApolloUploadServer::Upload,

          TrueClass => GraphQL::Types::Boolean,
          FalseClass => GraphQL::Types::Boolean,
          Float => GraphQL::Types::Float,
          Integer => GraphQL::Types::Int,
          String => GraphQL::Types::String,
          Object => GraphQL::Types::String,
          Symbol => GraphQL::Types::String,

          DateTime => Graphoid::Scalars::DateTime,
          Time => Graphoid::Scalars::DateTime,
          Date => Graphoid::Scalars::DateTime,
          Array => Graphoid::Scalars::Array,
          Hash => Graphoid::Scalars::Hash
        }
      end

      def class_of(relation)
        {
          mongo_constants[:many_to_many]  => ManyToMany,
          mongo_constants[:has_many]      => HasMany,
          mongo_constants[:has_one]       => HasOne,
          mongo_constants[:belongs_to]    => BelongsTo,
          mongo_constants[:embeds_many]   => EmbedsMany,
          mongo_constants[:embeds_one]    => EmbedsOne,
          mongo_constants[:embedded_in]   => Relation
        }[relation.relation] || Relation
      end

      def inverse_name_of(relation)
        relation.inverse_of
      end

      def fields_of(model)
        model.respond_to?(:fields) ? model.fields.values : []
      end

      def relations_of(model)
        model.relations
      end

      def skip(result, skip)
        result.skip(skip)
      end

      def relation_type(relation)
        relation.relation
      end

      # irep_node is deprecated
      #def eager_load(selection, model, first = true)
      #  referenced_relations = [
      #    mongo_constants[:many_to_many],
      #    mongo_constants[:has_many],
      #    mongo_constants[:has_one],
      #    mongo_constants[:belongs_to]
      #  ]

      #  properties = first ? Utils.first_children_of(selection) : Utils.children_of(selection)
      #  inclusions = Utils.symbolize(properties)

      #  Relation.relations_of(model).each do |name, relation|
      #    name = relation.name
      #    next if inclusions.exclude?(name) || referenced_relations.exclude?(relation.relation)

      #    subselection = properties[name.to_s.camelize(:lower)]
      #    subproperties = Utils.children_of(subselection)
      #    subchildren = Utils.symbolize(subproperties)
      #    subrelations = relation.class_name.constantize.relations.values.map(&:name)

      #    if (subrelations & subchildren).empty?
      #      model = model.includes(name)
      #    else
      #      begin
      #        gem "mongoid_includes"
      #        model = model.includes(name, with: ->(instance) { eager_load(subselection, instance, false) })
      #      rescue Gem::LoadError
      #        model = model.includes(name)
      #      end
      #    end
      #  end

      #  model
      #end

      def execute_and(scope, parsed)
        scope.and(parsed)
      end

      def execute_or(scope, list, context: nil)
        context ||= Graphoid::Queries::ExecutionContext.new

        list.map! do |object|
          Graphoid::Queries::Processor.execute(scope, object, context: context).selector
        end
        scope.any_of(list)
      end

      def parse(attribute, value, operator, prefix = nil)
        field = attribute.name
        field = "#{prefix}.#{field}" if prefix
        parsed = {}
        case operator
        when 'gt', 'gte', 'lt', 'lte', 'in', 'nin'
          parsed[field.to_sym.send(operator)] = value
        when 'regex'
          parsed[field.to_sym] = Regexp.new(value.to_s, Regexp::IGNORECASE)
        when 'contains'
          parsed[field.to_sym] = Regexp.new(Regexp.quote(value.to_s), Regexp::IGNORECASE)
        when 'not'
          if value.present? && !value.is_a?(Numeric)
            parsed[field.to_sym.send(operator)] = Regexp.new(Regexp.quote(value.to_s), Regexp::IGNORECASE)
          else
            parsed[field.to_sym.send(:nin)] = [value]
          end
        else
          parsed[field.to_sym] = value
        end
        parsed
      end

      def relate_embedded(scope, relation, filters, context: nil)
        # TODO: this way of fetching this is not recursive as the regular fields
        # because the structure of the query is embeeded.field = value
        # we need more brain cells on this problem because it does not allow
        # to filter things using OR/AND
        parsed = {}
        filters.each do |key, value|
          operation = Operation.new(scope, key, value, context: context)
          attribute = OpenStruct.new(name: "#{relation.name}.#{operation.operand}")
          obj = parse(attribute, value, operation.operator).first
          parsed[obj[0]] = obj[1]
        end
        parsed
      end

      def relate_one(scope, relation, value, context: nil)
        return relate_embedded(scope, relation, value, context: context) if relation.embeds_one?

        correlate_referenced_relation(scope, relation, value, 'some', context: context)
      end

      def relate_many(scope, relation, value, operator, context: nil)
        return {} if relation.embeds_many?
        return correlate_every_relation(scope, relation, value, context: context) if operator == 'every'

        correlate_referenced_relation(scope, relation, value, operator, context: context)
      end

      def correlate_referenced_relation(scope, relation, filters, operator, context: nil)
        parent_key, target_key = correlation_keys(relation)
        reachable_keys = project_distinct_keys(scope, parent_key)
        target_scope = correlated_target_scope(scope, relation, target_key, reachable_keys, context)
        matching_keys = matching_relation_keys(target_scope, target_key, filters, context)
        comparison = operator == 'none' ? 'nin' : 'in'

        parse(Attribute.new(name: parent_key, type: nil), matching_keys, comparison)
      end

      def correlate_every_relation(scope, relation, filters, context: nil)
        parent_key, target_key = correlation_keys(relation)
        reachable_keys = project_distinct_keys(scope, parent_key)
        target_scope = correlated_target_scope(scope, relation, target_key, reachable_keys, context)
        violating_keys = violating_relation_keys(target_scope, target_key, filters, context)

        parse(Attribute.new(name: parent_key, type: nil), violating_keys, 'nin')
      end

      def correlation_keys(relation)
        if relation.belongs_to? || relation.many_to_many?
          [relation.foreign_key, relation.primary_key]
        else
          [relation.primary_key, relation.foreign_key]
        end
      end

      def correlated_target_scope(parent_scope, relation, target_key, reachable_keys, context)
        return nil if reachable_keys.empty?

        correlation = parse(Attribute.new(name: target_key, type: nil), reachable_keys, 'in')
        authorized_scope = context.scope_for(
          relation.klass,
          relation: relation.metadata,
          parent_scope: parent_scope
        )
        execute_and(authorized_scope, correlation)
      end

      def matching_relation_keys(target_scope, target_key, filters, context)
        return [] unless target_scope

        matching_scope = Graphoid::Queries::Processor.execute(target_scope, filters, context: context)
        project_distinct_keys(matching_scope, target_key)
      end

      def violating_relation_keys(target_scope, target_key, filters, context)
        return [] unless target_scope

        matching_scope = Graphoid::Queries::Processor.execute(target_scope, filters, context: context)
        violating_scope = target_scope.and('$nor' => [matching_scope.selector])
        project_distinct_keys(violating_scope, target_key)
      end

      def project_distinct_keys(scope, field)
        criteria = scope.respond_to?(:selector) ? scope : scope.all
        storage_field = criteria.klass.database_field_name(field.to_s)
        max_keys = Graphoid.configuration.relation_filter_max_keys
        pipeline = projection_pipeline(criteria, storage_field, max_keys)
        keys = criteria.collection.aggregate(pipeline).map { |document| document['_id'] }

        return keys if keys.length <= max_keys

        raise RelationFilterCardinalityError,
              "Relation filter exceeded #{max_keys} distinct keys for #{criteria.klass.name}.#{field}"
      end

      def projection_pipeline(criteria, storage_field, max_keys)
        pipeline = []
        pipeline << { '$match' => criteria.selector } unless criteria.selector.empty?
        pipeline << { '$project' => { '__graphoid_key' => "$#{storage_field}" } }
        pipeline << { '$unwind' => '$__graphoid_key' }
        pipeline << { '$match' => { '__graphoid_key' => { '$ne' => nil } } }
        pipeline << { '$group' => { '_id' => '$__graphoid_key' } }
        pipeline << { '$limit' => max_keys + 1 }
        pipeline
      end
    end
  end
end

# frozen_string_literal: true

module Graphoid
  module Mutations
    def self.generate(*models)
      models.each { |model| Graphoid::Mutations.build(model) }
    end

    def self.build(model)
      Graphoid::Mutations::Create.build(model)
      Graphoid::Mutations::CreateOrUpdate.build(model)
      Graphoid::Mutations::Update.build(model)
      Graphoid::Mutations::Delete.build(model)
    end
  end
end

require 'graphoid/graphoid'
require 'graphoid/queries/queries'
require 'graphoid/mutations/structure'

Rails.application.config.after_initialize do
  Graphoid.configure do |config|
    config.driver = :mongoid
  end

  Graphoid.initialize
  Graphoid::Types::ProjectType = Class.new(GraphQL::Schema::Object)
  Graphoid::Types::UserType = Class.new(GraphQL::Schema::Object)
  Graphoid::Types::ProjectFilter = Class.new(GraphQL::Schema::InputObject)
  Graphoid::Types::UserFilter = Class.new(GraphQL::Schema::InputObject)
  Graphoid::Types::ProjectSorter = Class.new(GraphQL::Schema::InputObject)
  Graphoid::Types::UserSorter = Class.new(GraphQL::Schema::InputObject)
  Graphoid::Queries.build(Project)
  Graphoid::Queries.build(User)
  Graphoid::Mutations.build(User)
  Graphoid::Mutations.build(Project)
end

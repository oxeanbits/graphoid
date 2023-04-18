require 'graphoid/graphoid'
require 'graphoid/queries/queries'
require 'graphoid/mutations/structure'

Rails.application.config.after_initialize do
  Graphoid.configure do |config|
    config.driver = :mongoid
  end

  Graphoid.initialize
  Graphoid::Queries.build(User)
  Graphoid::Queries.build(Project)
  Graphoid::Mutations.build(User)
  Graphoid::Mutations.build(Project)

  #Project
  #User
end

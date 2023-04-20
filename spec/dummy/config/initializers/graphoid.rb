require 'graphoid/graphoid'
require 'graphoid/queries/queries'
require 'graphoid/mutations/structure'

Rails.application.config.after_initialize do
  Graphoid.configure do |config|
    config.driver = :mongoid
  end

  Graphoid.initialize
  Graphoid::Types.initialize(Project, User)
  Graphoid::Queries.generate(Project, User)
  Graphoid::Mutations.generate(Project, User)
end

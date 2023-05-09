# frozen_string_literal: true

Rails.application.config.after_initialize do
  Graphoid.configure do |config|
    config.driver = :mongoid
  end

  Graphoid.initialize
  Graphoid::Types.initialize(User, House, Label, Snake, Value, Person, Account, Contract, Level,
                             Player)
  Graphoid::Queries.generate(User, House, Label, Snake, Value, Person, Account, Contract, Player)
  Graphoid::Mutations.generate(User, House, Label, Snake, Value, Person, Account, Contract)
  Graphoid::Queries::Pagination.generate(Level)
end

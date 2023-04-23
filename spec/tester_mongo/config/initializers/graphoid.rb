Rails.application.config.after_initialize do
  Graphoid.configure do |config|
    config.driver = :mongoid
  end

  Graphoid.initialize
  Graphoid::Types.initialize(User, House, Label, Snake, Value, Person, Account, Contract)
  Graphoid::Queries.generate(User, House, Label, Snake, Value, Person, Account, Contract)
  Graphoid::Mutations.generate(User, House, Label, Snake, Value, Person, Account, Contract)
end

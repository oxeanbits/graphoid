require 'graphoid/mutations/create'
require 'graphoid/mutations/update'
require 'graphoid/mutations/delete'

module Graphoid
  module Mutations
    #include Graphoid::Mutations::Create
    #include Graphoid::Mutations::Update
    #include Graphoid::Mutations::Delete

    def self.build(model)
      Graphoid::Mutations::Create.build(model)
      Graphoid::Mutations::Update.build(model)
      Graphoid::Mutations::Delete.build(model)
    end
  end
end

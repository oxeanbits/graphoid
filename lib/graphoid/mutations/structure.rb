require 'graphoid/mutations/create'
require 'graphoid/mutations/update'

module Graphoid
  module Mutations
    extend ActiveSupport::Concern

    include Graphoid::Mutations::Create
    include Graphoid::Mutations::Update
    #include Graphoid::Mutations::Delete
  end
end

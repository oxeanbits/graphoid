require 'graphoid/mutations/create'
require 'graphoid/mutations/update'
require 'graphoid/mutations/delete'

module Graphoid
  module Mutations
    extend ActiveSupport::Concern

    include Graphoid::Mutations::Create
    include Graphoid::Mutations::Update
    include Graphoid::Mutations::Delete
  end
end

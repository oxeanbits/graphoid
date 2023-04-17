require 'graphoid/graphoid'

Rails.application.config.after_initialize do
  Graphoid.configure do |config|
    config.driver = :mongoid
  end

  Project
  User
end

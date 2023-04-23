# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

if Rails.env.development?
  require "sprockets/railtie"
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DummyRailsApp
  class Application < Rails::Application
    RAILS_VERSION = ENV["RAILS_VERSION"] || 7.0
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults RAILS_VERSION

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    if Rails.env.development?
      config.middleware.use ActionDispatch::Cookies
      config.middleware.use ActionDispatch::Session::CookieStore
      config.session_store :cookie_store, key: '_graphql-rails-sample'
    end
  end
end

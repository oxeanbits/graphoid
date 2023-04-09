# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

require 'spec_helper'
require 'pry-rails'

ENV['RAILS_ENV'] ||= 'test'

tests_folder = "tester_#{ENV['DRIVER'] || 'ar'}"

require File.expand_path("../#{tests_folder}/config/environment", __FILE__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

RSpec.configure(&:filter_rails_from_backtrace!)

module Helper
  def self.resolve(test, action, query)
    test.post '/graphql', params: { query: query }
    body = test.response.body
    pp body if ENV['DEBUG']
    result = JSON.parse(body)['data']
    result && result[action]
  end

  def self.ids_of(*objects)
    objects.map(&:id).map(&:to_s)
  end
end

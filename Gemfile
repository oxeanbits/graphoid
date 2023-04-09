# frozen_string_literal: true

source 'https://rubygems.org'
ruby '~> 3.0.0'

gemspec

#gem 'graphql', '~> 1.8.0'
gem 'graphql', git: 'https://github.com/oxeanbits/graphql-ruby.git', branch: 'ruby3-1.8.18'

gem 'nokogiri', '~> 1.13.9'

gem 'activemodel', '>= 5.1'
gem 'actionpack', '>= 6.0.1'

group :development, :test do
  gem 'byebug'
  gem 'simplecov', require: false
  gem 'pry-rails', '~> 0.3.4'

  # Adds step-by-step debugging and stack navigation capabilities to pry using byebug.
  gem 'pry-byebug'
end

group :test do
  gem 'mongoid'
  gem 'mongoid-rspec'
  gem 'rspec'
  gem 'rspec-rails', '>= 6.0'
  gem 'sqlite3'
end

class User < ApplicationRecord
  include ActiveModel::SecurePassword
  include Mongoid::Document
  include Mongoid::Timestamps

  has_secure_password

  belongs_to :project

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze

  # rubocop:disable Style/RegexpLiteral
  # https://stackoverflow.com/a/70338667/7644846
  VALID_PASSWORD_REGEX = %r{^(?=[^A-Z\n]*[A-Z])(?=[^a-z\n]*[a-z])
                             (?=[^0-9\n]*[0-9])
                             (?=[^#?!@$%^&*\n-]*[#?!@$%^&*-])
                             .{8,}$}x.freeze
  # rubocop:enable Style/RegexpLiteral

  field :name, type: String
  field :email, type: String
  field :active, type: Boolean, default: true
  field :metadata, type: Hash
  field :project_ids, type: Array

  #graphield :password, type: String
  #graphield :password_confirmation, type: String

  ## this is an API hidden field. Not accessible in graphql
  #graphorbid :token, type: String
  #graphorbid :password_digest, type: String
  field :password_digest, type: String

  #include Graphoid::Queries
  #include Graphoid::Mutations

  validates :id, presence: true
  validates :name, presence: true
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password_digest, presence: true
  validates :active, presence: true
  validates :project_ids, presence: true
end

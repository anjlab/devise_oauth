require 'active_support/core_ext'
require 'devise'

module Devise
  module Oauth
    mattr_accessor :resource_owner
    @@resource_owner = "User"

    mattr_accessor :client_owner
    @@client_owner = self.resource_owner

    mattr_accessor :scopes
    @@scopes = []

    mattr_accessor :access_token_expires_in
    @@access_token_expires_in = 1.hour

    mattr_accessor :authorization_code_expires_in
    @@authorization_code_expires_in = 1.minute

    mattr_accessor :generate_refresh_token
    @@generate_refresh_token = true

    mattr_accessor :regenerate_refresh_token
    @@regenerate_refresh_token = true

    mattr_accessor :supported_grant_types
    @@supported_grant_types = [:authorization_code, :password, :refresh_token]

    def self.friendly_token(length = 20)
      SecureRandom.base64(length).tr('+/=lIO0', 'pqrsxyz')
    end
  end
end

require "devise/oauth/scopable"
require "devise/oauth/blockable"

require "devise/models/client_ownable"
require "devise/models/resource_ownable"

require "devise/strategies/access_token_authenticatable"
require "devise/models/access_token_authenticatable"


require "devise/oauth/engine"

Devise.add_module(
  :access_token_authenticatable,
  :strategy => true,
  :model => 'devise/models/access_token_authenticatable'
)
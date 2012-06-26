require 'devise/strategies/base'

module Devise
  module Strategies
    class AccessTokenAuthenticatable < Authenticatable
      def store?
        false # no no for session here
      end

      def valid?
        @access_tokens = [access_token_in_header, access_token_in_payload].compact
        @access_tokens.present?
      end

      def authenticate!
        if @access_tokens.length > 1
          return fail(:invalid_token)
        end

        access_token = Devise::Oauth::AccessToken.where(value: @access_tokens.first).first
        return fail(:invalid_token) unless access_token

        resource = access_token.resource_owner
        if validate(resource)
          env["devise.oauth.access_token"] = access_token
          resource.oauth_token = access_token
          success!(resource)
        else
          oauth_error!
        end
      end

    private
      def oauth_error!(error_code = :invalid_request, description = nil)
        body = {:error => error_code}
        body[:error_description] = description if description
        custom! [400, {'Content-Type' => 'application/json'}, [body.to_json]]
      end

      # Access Token Authenticatable can be authenticated with params in any controller and any verb.
      def valid_params_request?
        true
      end

      # Do not use remember_me behavior with token.
      def remember_me?
        false
      end

      def access_token_in_payload
        params['access_token']
      end

      def access_token_in_header
        auth_header = ::Rack::Auth::AbstractRequest.new(env)
        if auth_header.provided? && auth_header.scheme == :bearer
          auth_header.params
        else
          nil
        end
      end

    end
  end
end

Warden::Strategies.add(:access_token_authenticatable, Devise::Strategies::AccessTokenAuthenticatable)

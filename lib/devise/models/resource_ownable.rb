module Devise
  module Models
    module ResourceOwnable
      extend ActiveSupport::Concern
      included do

        has_many :oauth_access_tokens,
                 class_name: "Devise::Oauth::AccessToken",
                foreign_key: "resource_owner_id",
                  dependent: :destroy

        has_many :oauth_authorizations,
                 class_name: "Devise::Oauth::Authorization",
                foreign_key: "resource_owner_id",
                  dependent: :destroy
        
        has_many :oauth_accesses,
                     class_name: "Devise::Oauth::Access",
                    foreign_key: "resource_owner_id",
                      dependent: :destroy

        attr_accessor :oauth_token
      end

      def oauth_token?
        oauth_token.present?
      end

      def oauth_scope? *scope
        return false if oauth_token.nil?

        oauth_token.has_scope? scope
      end
    end
  end
end

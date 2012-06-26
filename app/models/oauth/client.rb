module Devise::Oauth 
  class Client < ActiveRecord::Base
    def self.client_ownable?
      Devise::Oauth.client_owner.constantize.devise_modules.include? :client_ownable
    end
   
    belongs_to :owner, class_name: Devise::Oauth.client_owner if self.client_ownable?
    
    has_many :access_tokens,  class_name: "Devise::Oauth::AccessToken",   dependent: :destroy
    has_many :authorizations, class_name: "Devise::Oauth::Authorization", dependent: :destroy
    has_many :accesses,       class_name: "Devise::Oauth::Access",        dependent: :destroy

    validates :name,     presence: true
    validates :owner_id, presence: true
    validates :site_uri, presence: true

    serialize :redirect_uris, Array

    include Devise::Oauth::Scopable
    include Devise::Oauth::Blockable

    def block!
      super
      AccessToken.block_client!  id
      Authorization.block_client! id
    end

    before_create :generate_identifier
    before_create :generate_secret

    def granted!
      self.class.update_counters(id, granted_times: 1)
    end

    def revoked!
      self.class.update_counters(id, revoked_times: 1)
    end

    private

    def generate_identifier
      self.identifier = Devise::Oauth.friendly_token
    end

    def generate_secret
      self.secret = Devise::Oauth.friendly_token
    end 
  end
end
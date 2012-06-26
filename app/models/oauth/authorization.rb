class Devise::Oauth::Authorization < ActiveRecord::Base
  belongs_to :client,         class_name: "Devise::Oauth::Client"
  belongs_to :resource_owner, class_name: Devise::Oauth.resource_owner

  validates :client_id,         presence: true
  validates :resource_owner_id, presence: true

  before_create :generate_code
  before_create :create_expiration

  include Devise::Oauth::Scopable
  include Devise::Oauth::Blockable

  attr_accessible :client, :resource_owner, :scope

  def expired?(at = Time.now)
    self.expires_at < at
  end

  def expire!(at = Time.now)
    self.expires_at = at
    save
  end

  def used!(at = Time.now)
    self.used_at = at
    save
    # TODO: May be we should destroy it instead?
  end

  def used?
    !!self.used_at
  end

  def valid_redirect_uri? uri
    if redirect_uri.blank?
      client.redirect_uris.include? uri
    else
      self.redirect_uri = uri
    end
  end

  def create_access_token
    Devise::Oauth::AccessToken.create client: client, resource_owner: resource_owner, scope: scope
  end

  private

  def generate_code
    self.code = Devise::Oauth.friendly_token
  end

  def create_expiration
    self.expires_at = Time.now + Devise::Oauth.authorization_code_expires_in
  end

  
end
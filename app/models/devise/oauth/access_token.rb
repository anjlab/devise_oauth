class Devise::Oauth::AccessToken < ActiveRecord::Base
  belongs_to :client,         class_name: "Devise::Oauth::Client"
  belongs_to :resource_owner, class_name: Devise::Oauth.resource_owner

  validates :client_id,         presence: true
  validates :resource_owner_id, presence: true

  before_create :generate_refresh_token if Devise::Oauth.generate_refresh_token

  before_create :generate_value
  before_create :setup_expiration

  include Devise::Oauth::Scopable
  include Devise::Oauth::Blockable

  def expired?(at = Time.now)
    self.expires_at < at
  end

  def refresh!
    generate_refresh_token if Devise::Oauth.regenerate_refresh_token

    generate_value
    setup_expiration

    save
    token_response(Devise::Oauth.regenerate_refresh_token)
  end

  def refresh_token_expired?
    self.refresh_token_expires_at < Time.now
  end

  def token_response(generated_refresh_token=true)
    res = {
      access_token: value,
      token_type: 'bearer'
    }
    res[:scope]         = scope_to_response if scope.present?
    res[:expires_in]    = Devise::Oauth.access_token_expires_in if Devise::Oauth.access_token_expires_in
    res[:refresh_token] = refresh_token if generated_refresh_token
    res
  end

  private

  def generate_value
    self.value = Devise.friendly_token
  end

  def setup_expiration
    self.expires_at = Time.now + Devise::Oauth.access_token_expires_in
  end

  def generate_refresh_token
    self.refresh_token = Devise::Oauth.friendly_token
  end

end
class Devise::Oauth::Access < ActiveRecord::Base
  belongs_to :client,         class_name: "Devise::Oauth::Client"
  belongs_to :resource_owner, class_name: Devise::Oauth.resource_owner

  validates :client_id,         presence: true
  validates :resource_owner_id, presence: true

  include Devise::Oauth::Blockable

  def block!
    super
    Devise::Oauth::AccessToken.block_access!(client_id, resource_owner_id)
    Devise::Oauth::Authorization.block_access!(client_id, resource_owner_id)
  end

  def accessed!
    self.class.update_counters(id, accessed_times: 1)
  end
end
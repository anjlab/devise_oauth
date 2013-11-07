module Devise::Oauth::Blockable
  extend ActiveSupport::Concern

  def block!(at = Time.now)
    self.blocked_at = at
    save
  end

  def blocked?
    blocked_at.present?
  end

  def unblock!
    self.blocked_at = nil
    save
  end

  module ClassMethods
    def block_access!(client_id, resource_owner_id)
      where(client_id: client_id, resource_owner_id: resource_owner_id).update_all(blocked_at: Time.now)
    end

    def block_client!(client_id)
      where(client_id: client_id).update_all(blocked_at: Time.now)
    end
  end
end
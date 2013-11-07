module Devise::Oauth::Helpers

  def normalize_scope
    scope = (params[:scope] || "").split(" ")
    scope_mask = Devise::Oauth::AccessToken.scope_to_mask(scope)
    @requested_scope = Devise::Oauth::AccessToken.mask_to_scope(scope_mask)

    scope_mask = @client.scope_mask & scope_mask
    scope_mask = @authorization.scope_mask & scope_mask if @authorization
    scope_mask = @refresh_token.scope_mask & scope_mask if @refresh_token

    @scope = Devise::Oauth::AccessToken.mask_to_scope(scope_mask)
  end

  def client_blocked?
    blocked_client if @client.blocked?
  end

  def access_blocked?
    @access = Devise::Oauth::Access.find_or_create_by(client_id: @client.id, resource_owner_id: @resource_owner.id)
    blocked_token if @access.blocked?
  end

end
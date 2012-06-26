class Devise::Oauth::AuthorizationsController < ApplicationController 
  include Devise::Oauth::Helpers

  before_filter :authenticate_user! # TODO: use devise scope here
  before_filter :find_client
  before_filter :find_resource_owner
  before_filter :normalize_scope
  # before_filter :check_scope          # check if the access is authorized
  before_filter :client_blocked?      # check if the client is blocked
  before_filter :access_blocked?      # check if user has blocked the client

  # before_filter :token_blocked?, only: :show   # check for an existing token
  # before_filter :refresh_token,  only: :show   # create a new token

  def show
  end

  def create
    @client.granted!

    # section 4.1.1 - authorization code flow
    if params[:response_type] == "code"
      @authorization = Devise::Oauth::Authorization.create(client: @client, resource_owner: @resource_owner, scope: @scope)
      redirect_to authorization_redirect_uri(@client, @authorization, params[:state])
    end

    # section 4.2.1 - implicit grant flow
    if params[:response_type] == "token"
      @token = Devise::Oauth::AccessToken.create(client: @client, resource_owner: @resource_owner, scope: scope)
      redirect_to implicit_redirect_uri(@client, @token, params[:state])
    end
  end

  def destroy
    @client.revoked!
    redirect_to deny_redirect_uri(params[:response_type], params[:state])
  end

  private

  def authorization_redirect_uri(client, authorization, state)
    uri  = client.redirect_uris.first
    uri += "?code="  + authorization.code
    uri += "&state=" + state if state
    uri
  end

  def implicit_redirect_uri(client, token, state)
    uri  = client.redirect_uris.first
    uri += "#token=" + token.token
    uri += "&expires_in=" + Oauth.settings["token_expires_in"]
    uri += "&state=" + state if state
    return uri
  end

  def deny_redirect_uri(response_type, state)
    uri = @client.redirect_uris.first
    uri += (response_type == "code") ? "?" : "#"
    uri += "error=access_denied"
    uri += "&state=" + state if state
    return uri
  end

  def find_resource_owner
    @resource_owner = current_user
  end

  def find_client
    client_id = params[:client_id]

    @client = Devise::Oauth::Client.where(identifier: client_id).first

    client_not_found if @client.blank?
  end

  def invalid_request
    raise "sd"
  end

  def client_not_found
    rails "bla"
  end

end
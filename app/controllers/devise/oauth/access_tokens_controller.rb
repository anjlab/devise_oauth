class Devise::Oauth::AccessTokensController < ApplicationController

  include Devise::Oauth::Helpers

  # create access_token flows
  cattr_accessor :flows
  @@flows = {
    ## section 4.1.3 (authorization code flow)
    authorization_code: [
      :find_auth_by_code,
      :normalize_scope,
      :access_blocked?,
      :create_token_from_auth
    ],

    ## section 4.3.2 (Resource Owner Password Credentials flow)
    password: [
      :authenticate_resource_owner,
      :normalize_scope,
      :access_blocked?,
      :create_token
    ],
    # section 6.0 (refresh token)
    refresh_token: [
      :find_refresh_token,
      :normalize_scope,
      :access_blocked?,
      :create_token_from_refresh
    ]
  }
  
  ## common flow
  before_action :find_client,      only: :create
  before_action :client_blocked?,  only: :create
  before_action :find_grant_type,  only: :create
  before_action :execute_flow,     only: :create

  def create
    render json: @token_response
    @authorization.used! if @authorization
  end

  def destroy
  end

  private

  def find_client
    client_id, client_secret = request.authorization ?
      decode_credentials : [params[:client_id], params[:client_secret]]

    if client_id.blank? || client_secret.blank? 
      return invalid_request
    end    

    @client = Devise::Oauth::Client.where(identifier: client_id).first

    return client_not_found if @client.blank? || @client.secret != client_secret
  end


  def find_grant_type
    @grant_type = case params[:grant_type]
    when "authorization_code" 
      :authorization_code
    when "password" 
      :password
    when "refresh_token" 
      :refresh_token
    when "client_credentials"
      :client_credentials
    else      
      :unsupported
    end

    return invalid_grant_type(params[:grant_type]) if !Devise::Oauth.supported_grant_types.include?(@grant_type)
  end

  def execute_flow
    flow = self.class.flows[@grant_type]
    flow.each do |method|
      break if response_body
      send(method)
    end
  end

  def resource_owner_credentials_flow?
    @grant_type == :password
  end

  # tokens responses

  def create_token_from_auth
    @token_response = @authorization.create_access_token.token_response
  end

  def create_token_from_refresh
    @token_response = @refresh_token.refresh!
  end

  def create_token
    @token_response = Devise::Oauth::AccessToken.create(client: @client, resource_owner: @resource_owner, scope: @scope).token_response
  end

  def find_auth_by_code
    code = params[:code]
    
    @authorization = @client.authorizations.where(code: code).first
    return auth_not_found if @authorization.blank?
    return access_denied if @authorization.used?
    return invalid_request if !@authorization.valid_redirect_uri?(params[:redirect_uri])
    return auth_expired if @authorization.expired?
    @resource_owner = @authorization.resource_owner
  end

  def find_refresh_token
    refresh_token = params[:refresh_token]

    return invalid_request if refresh_token.blank? 

    @refresh_token = @client.access_tokens.where(refresh_token: params[:refresh_token]).first

    return invalid_request if @refresh_token.blank?
    @resource_owner = @refresh_token.resource_owner
  end

  def authenticate_resource_owner
    owner_class = Devise::Oauth.resource_owner.constantize
    owner = owner_class.find_for_authentication(owner_class.authentication_keys.first => params[:username])
    if owner && owner.valid_password?(params[:password])
      @resource_owner = owner
    else
      invalid_request
    end
  end

  

  # errors

  def auth_not_found
    render_error :unprocessable_entity, error: "invalid_request", error_description: "Authorization not found"
  end

  def auth_expired
    render_error :unprocessable_entity, error: "invalid_request", error_description: "Authorization expired"
  end

  def client_not_found
    render_error :unprocessable_entity, error: "invalid_request", error_description: "Client not found"
  end

  def access_denied
    render_error :unauthorized, error: "invalid_request"
  end

  def invalid_request
    render_error :bad_request, error: "invalid_request"
  end

  def invalid_client
    render_error :unauthorized, error: "invalid_client"
    ## TODO: check authorization
  end

  def blocked_client
    render_error :unprocessable_entity, error: "invalid_request", error_description: "Client Blocked"
  end

  def blocked_token
    render_error :unprocessable_entity, error: "invalid_request", error_description: "Client blocked from the user"
  end

  def invalid_grant
    render_error :bad_request, error: "invalid_grant"
  end

  def render_error status, info
    render json: info, status: status
  end


end
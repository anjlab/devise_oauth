require 'spec_helper'

shared_examples "client is blocked flow" do
  before do
    client.block!
    post :create, attributes
  end

  it { should respond_with :unprocessable_entity }
  it { should respond_with_content_type :json }
  it "should have error 'invalid_request'" do
    res = JSON.load(response.body)
    res['error'].should == "invalid_request"
    res['error_description'].should == "Client Blocked"
  end
end

shared_examples "access is blocked (resource owner block a client) flow" do
  before do
    access.block!
    post :create, attributes
  end
  it { should respond_with :unprocessable_entity }
  it { should respond_with_content_type :json }
end

shared_examples "invalid client_id flow" do
  before do
    attributes.merge!(client_id: "not_existing")
    post :create, attributes
  end

  it { should respond_with :unprocessable_entity }
  it { should respond_with_content_type :json }

  it "should have error 'invalid_request'" do
    res = JSON.load(response.body)
    res['error'].should == "invalid_request"
    res['error_description'].should == "Client not found"
  end
end

describe Devise::Oauth::AccessTokensController do
  before(:each) { 
    @routes = Devise::Oauth::Engine.routes
    @user   = create(:user)
    @client = create(:client)
    @authorization = create(:authorization, client: @client, resource_owner: @user)
    @access = create(:access, client: @client, resource_owner: @user) 
  }

  let(:user)          { @user }
  let(:client)        { @client }
  let(:authorization) { @authorization }
  let(:access)        { @access}
  
  context "Authorization code" do
    let(:attributes) { 
      { 
        grant_type: "authorization_code",
        client_id: client.identifier,
        client_secret: client.secret,
        code: authorization.code,
        redirect_uri: client.redirect_uris.first
      }
    }

    context "main flow" do
      before do
        post :create, attributes
      end
      let (:access_token) { @access_token = Devise::Oauth::AccessToken.last }

      it { should respond_with :ok }
      it { should respond_with_content_type :json }
      it "should create new access token" do
        access_token.should be_present
      end

      it "has valid access token in response" do
        response.body.should match_json(access_token.token_response)
      end
    end

    context "not valid code flow" do
      before do
        attributes.merge!(code: "not_existing")
        post :create, attributes
      end

      it { should respond_with :unprocessable_entity }
      it { should respond_with_content_type :json }
      it "should have error 'invalid_request'" do
        res = JSON.load(response.body)
        res['error'].should == "invalid_request"
        res['error_description'].should == "Authorization not found"
      end
    end

    context "authorization is expired flow" do
      before do
        authorization.expire!
        post :create, attributes
      end

      it { should respond_with :unprocessable_entity }
      it { should respond_with_content_type :json }

      it "should have error 'invalid_request'" do
        res = JSON.load(response.body)
        res['error'].should == "invalid_request"
        res['error_description'].should == 'Authorization expired'
      end
    end

    it_behaves_like "client is blocked flow"
    it_behaves_like "access is blocked (resource owner block a client) flow"
    it_behaves_like "invalid client_id flow"
  end

  context "Password credentials" do
    let(:attributes) {
      { 
        grant_type: "password",
        client_id: client.identifier,
        client_secret: client.secret,
        username: user.email,
        password: user.password,
        scope: ""
      }
    }

    context "main flow" do
      before do 
        post :create, attributes
      end
      let (:access_token) { @access_token = Devise::Oauth::AccessToken.last }

      it { should respond_with :ok }
      it { should respond_with_content_type :json }
      it "should create new access token" do
        access_token.should be_present
      end

      it "has valid access token in response" do
        response.body.should match_json(access_token.token_response)
      end
    end

    context "not valid user password flow" do
      before do
        attributes.merge!(password: "not_existing")
        post :create, attributes
      end
      ## TODO: bad request? or may be unauthorized?
      it { should respond_with :bad_request }
      it { should respond_with_content_type :json }
    end

    it_behaves_like "client is blocked flow"
    it_behaves_like "access is blocked (resource owner block a client) flow"
    it_behaves_like "invalid client_id flow"
  end

  context "Refresh Token" do
    let(:token) { create(:access_token, resource_owner: user, client: client) }

    let(:attributes) {
      { 
        grant_type: "refresh_token",
        refresh_token: token.refresh_token,
        client_id: client.identifier,
        client_secret: client.secret 
      }
    }

    context "main flow" do
      before do 
        post :create, attributes
      end
      let (:access_token) { @access_token = Devise::Oauth::AccessToken.last }

      it { should respond_with :ok }
      it { should respond_with_content_type :json }
      it "should create new access token" do
        access_token.should be_present
      end

      it "has valid access token in response" do
        response.body.should match_json(access_token.token_response)
      end
    end

    context "no valid refresh token flow" do
      before do
        attributes.merge!(refresh_token: "not_existing")
        post :create, attributes
      end
      it { should respond_with :bad_request }
      it { should respond_with_content_type :json }
      # page.should have_content "Refresh token not found"
    end

    it_behaves_like "client is blocked flow"
    it_behaves_like "access is blocked (resource owner block a client) flow"
    it_behaves_like "invalid client_id flow"
  end
end
require 'spec_helper'

describe ProtectedResourcesController do
  before(:each) {
    @user   = create(:user)
    @client = create(:client)
    @authorization = create(:authorization, client: @client, resource_owner: @user)
    @token  = @authorization.create_access_token
    @access = create(:access, client: @client, resource_owner: @user) 
  }

  let(:user)          { @user }
  let(:client)        { @client }
  let(:authorization) { @authorization }
  let(:access)        { @access }
  let(:token)         { @token }

  context "Access protected resources with default scope" do
    let(:attributes) {
      { access_token: @token.value }
    }

    context "can read resources" do
      before do
        get :index, attributes
      end

      it { should respond_with :ok }
      it { response.content_type.should == "application/json" }
    end

    context "can't write protected resources" do
      before do
        post :create, attributes
      end

      it { should respond_with :forbidden }
      it { response.content_type.should == "application/json" }
    end

    context "can't access protected resource with invalid access token" do
      before do
        attributes.merge!(access_token: 'not valid')
        get :index, attributes
      end

      it { should respond_with :forbidden }
      # it { should respond_with_content_type :json }
    end

    context "can't access protected resource with blocked access token" do
      before do
        @token.block!
        get :index, attributes
      end

      it { should respond_with :forbidden }
      # it { should respond_with_content_type :json }
    end
  end

  context "Access protected resources with default scope" do
    before do
      @authorization = create(:authorization, client: @client, resource_owner: @user, scope: [:write])
      @token  = @authorization.create_access_token
    end
    let(:attributes) { 
      { access_token: @token.value }
    }

    context "can read resources" do
      before do
        get :index, attributes
      end

      it { should respond_with :ok }
      it { response.content_type.should == "application/json" }
    end

    context "can write protected resources" do
      before do
        post :create, attributes
      end

      it { should respond_with :ok }
      it { response.content_type.should == "application/json" }
    end
  end
end
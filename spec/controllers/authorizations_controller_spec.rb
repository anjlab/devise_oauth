require 'spec_helper'

describe Devise::Oauth::AuthorizationsController do
  render_views

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

  context "Authorization code flow" do
    before { sign_in user }
    let(:attributes) {
      {
        client_id: client.identifier,
        redirect_uri: client.redirect_uris.first,
        response_type: 'code'
      }
    }

    context "when valid" do
      before { get :show, attributes }

      it { should respond_with :ok }
      it { should respond_with_content_type :html }
      it { should render_template 'devise/oauth/authorizations/show' }
      it { should render_with_layout 'application' }
      it "renders client name" do
        response.body.should include(client.name)
      end

      context "#grant" do
        before { post :create, attributes }
        it { should respond_with :redirect }
        it { should respond_with_content_type :html }
      end

      context "#deny" do
        before { delete :destroy, attributes }
        it { should respond_with :redirect }
        it { should respond_with_content_type :html }
      end
    end
  end
end

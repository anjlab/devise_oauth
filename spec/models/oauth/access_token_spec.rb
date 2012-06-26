require 'spec_helper'

describe Devise::Oauth::AccessToken do
  before  { @token = create(:access_token) }
  subject { @token }

  it { should validate_presence_of(:client_id) }
  it { should validate_presence_of(:resource_owner_id) }

  it { should belong_to(:client) }
  it { should belong_to(:resource_owner) }

  it { should have_db_index(:value).unique(true) }
  it { should have_db_index(:refresh_token).unique(true) }
  it { should have_db_index(:client_id).unique(false) }

  its(:value) { should_not be_nil }
  its(:refresh_token) { should_not be_nil }
  its(:expires_at) { should_not be_nil }
  it { should_not be_blocked }

  it "refreshes value" do
    expect{ subject.refresh! }.to change { subject.value }
  end
end
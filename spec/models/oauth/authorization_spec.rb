require 'spec_helper'

describe Devise::Oauth::Authorization do
  before  { @auth = create(:authorization) }
  subject { @auth }

  it { should validate_presence_of(:client_id) }
  it { should validate_presence_of(:resource_owner_id) }

  it { should belong_to(:client) }
  it { should belong_to(:resource_owner) }

  it { should have_db_index(:code).unique(true) }
  it { should have_db_index(:client_id).unique(false) }

  its(:code) { should_not be_nil }
  its(:expires_at) { should_not be_nil }
  it { should_not be_blocked }
end
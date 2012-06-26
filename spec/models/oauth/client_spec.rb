require 'spec_helper'

describe Devise::Oauth::Client do
  before { @client = create(:client) }
  subject { @client }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:site_uri) }

  it { should belong_to(:owner) }

  it { should have_many(:access_tokens) }
  it { should have_many(:authorizations) }

  it { should have_db_index(:identifier).unique(true) }
  it { should have_db_index(:secret).unique(true) }
  it { should have_db_index(:owner_id).unique(false) }

  its(:identifier) { should_not be_nil }
  its(:secret) { should_not be_nil }

  it { should_not be_blocked }

  it ".granted!" do
    lambda{ subject.granted! }.should change{ subject.reload; subject.granted_times }.by(1)
  end

  it ".revoked!" do
    lambda{ subject.revoked! }.should change{ subject.reload; subject.revoked_times }.by(1)
  end
end
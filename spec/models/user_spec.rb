require 'spec_helper'

describe User do

  it { should have_many(:oauth_clients) }
  it { should have_many(:oauth_access_tokens) }
  it { should have_many(:oauth_authorizations) }
  it { should have_many(:oauth_accesses) }

end

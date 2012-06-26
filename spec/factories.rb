FactoryGirl.define do
  factory :user do
    email "alice@example.com"
    password "example"
  end

  factory :client_owner, parent: :user do
    email "bob@example.com"
    password "example"
  end

  factory :client, class: Devise::Oauth::Client do
    name "super client"
    site_uri "http://localhost"
    redirect_uris ["http://localhost:3000/callback"]
    association :owner, factory: :client_owner
  end

  factory :access_token, class: Devise::Oauth::AccessToken do
    association :client, factory: :client
    association :resource_owner, factory: :user
  end

  factory :authorization, class: Devise::Oauth::Authorization do
    association :client, factory: :client
    association :resource_owner, factory: :user
    redirect_uri "http://localhost:3000/callback"
  end

  factory :access, class: Devise::Oauth::Access do
    association :client, factory: :client
    association :resource_owner, factory: :user
  end
end
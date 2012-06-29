# Devise::Oauth

## Installation

Add it to your Gemfile

```ruby
gem 'devise_oauth'
```

Mount engine in your routes.rb file

```ruby
mount Devise::Oauth::Engine => '/oauth'
```

Define possible scopes in your application.rb

```ruby
Devise::Oauth.scopes = [:read, :write]
```

Add strategies to your User model

```ruby
class User < ActiveRecord::Base
  devise :database_authenticatable,
         #:registerable,
         #:recoverable,
         #:rememberable,
         #:trackable,
         #:omniauthable,

         # OAuth provider
         :access_token_authenticatable,
         :client_ownable,
         :resource_ownable
```

Create migration [TODO: write generator]

look at `db/migrate/20120622164619_devise_create_oauth.rb` for now

## CanCan support

if your app is accessed with `access_token` then we set it as `oauth_token` to current_user

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.oauth_token?
      # has access_token, so we set access rights with scope
      setup_client(user)
    else
      # normal user access rights setup
      setup(user)
    end

    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end

  private

  def setup_client(user)
    if user.oauth_scope? :write
      can :create, :protected_resource
    end
  end

  def setup(user)

  end
end
```


This project rocks and uses MIT-LICENSE.
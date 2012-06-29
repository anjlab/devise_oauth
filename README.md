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


This project rocks and uses MIT-LICENSE.
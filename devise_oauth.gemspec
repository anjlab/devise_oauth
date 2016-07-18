$:.push File.expand_path("../lib", __FILE__)

require "devise/oauth/version"

Gem::Specification.new do |s|
  s.name        = "devise_oauth"
  s.version     = Devise::Oauth::VERSION
  s.authors     = ["Yury Korolev"]
  s.email       = ["yury.korolev@gmail.com"]
  s.homepage    = "https://github.com/anjlab/devise_oauth"
  s.summary     = "Oauth 2.0 provider implementation on top of devise."
  s.description = "The OAuth 2.0 Authorization Framework draft-ietf-oauth-v2-28 implementation on top of devise."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", ">= 3.0.0"
  s.add_dependency "devise", ">= 2.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "rspec-rails", ">= 2.0"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "shoulda-matchers"
end

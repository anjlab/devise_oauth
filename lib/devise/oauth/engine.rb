module Devise::Oauth
  class Engine < ::Rails::Engine

    NAME = "oauth"

    def table_name_prefix
      NAME
    end

    def self.generate_railtie_name(mod)
      NAME
    end

    engine_name NAME

    isolate_namespace Devise::Oauth

    initializer "devise_oauth.initialize_application", before: :load_config_initializers do |app|
      app.config.filter_parameters << :client_secret
      app.config.filter_parameters << :refresh_token
    end
  end
end

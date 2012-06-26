module Devise
  module Models
    module ClientOwnable
      extend ActiveSupport::Concern
      included do
        
        has_many :oauth_clients,
                     class_name: "Devise::Oauth::Client",
                    foreign_key: "owner_id",
                      dependent: :destroy
      end
    end
  end
end

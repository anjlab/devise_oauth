module Devise::Oauth::Scopable
  extend ActiveSupport::Concern

  def scope=(scope)
    self.scope_mask = self.class.scope_to_mask(scope)
  end

  def scope
    self.class.mask_to_scope(scope_mask)
  end

  def has_scope?(scope)
    self.scope_mask & self.class.scope_to_mask(scope) > 0
  end

  def scope_to_response
    scope.join(" ")
  end

  module ClassMethods
    def scopes
      @@scopes ||= Devise::Oauth.scopes.map {|s| s.to_s}
    end

    def scope_to_mask(scope=[])
      return 0 if scope.blank?
      (scope.map(&:to_s) & scopes).map { |r| 2**scopes.index(r) }.sum
    end

    def mask_to_scope(mask)
      return [] if mask == 0
      scopes.reject {|r| (mask & 2**scopes.index(r)).zero? }
    end

    def where_scope(scope=[])
      if scope.blank?
        where "scope_mask = 0"
      else
        where "scope_mask & ? > 0", scope_to_mask(scope)
      end
    end
  end
end
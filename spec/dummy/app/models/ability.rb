class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.oauth_token?
      can :index, :protected_resource
    end

    if user.oauth_scope? :write
      can :create, :protected_resource
    end
  end
end
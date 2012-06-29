class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    render json: {error: :access_denied}, status: :forbidden
  end
end

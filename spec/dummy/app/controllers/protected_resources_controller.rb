class ProtectedResourcesController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :index, :protected_resource
    render json: {}
  end

  def create
    authorize! :create, :protected_resource
    render json: {}
  end

end
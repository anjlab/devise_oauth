class ProtectedResourcesController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :index, :protected_resource
    render json: {}
  end

  def create
    authorize! :create, :protected_resource
    render json: {}
  end

end
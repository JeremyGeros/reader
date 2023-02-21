class SessionsController < ApplicationController
  skip_before_action :require_user, only: [:new, :create]
  before_action :require_no_user, only: [:new, :create]

  def new
    params[:full_size] = true
  end

  def create
    if verify_and_login!(params[:email], params[:password])
      redirect_to root_url, notice: "Logged in!"
    else
      flash.now[:alert] = "Email or password is invalid"
      render "new"
    end
  end
  
  def destroy
    logout!
    redirect_to root_url, notice: "Logged out!"
  end
end

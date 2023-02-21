class SignupController < ApplicationController
  skip_before_action :require_user, only: [:new, :create]
  before_action :require_no_user, only: [:new, :create]
  
  def new
    @user = User.new
    params[:full_size] = true
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        login_user!(@user)
        format.html { redirect_to root_url, notice: 'User was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end

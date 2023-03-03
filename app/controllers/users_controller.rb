class UsersController < ApplicationController
  before_action :require_user
  before_action :set_user, only: [:edit, :update, :destroy]

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render json: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
    end
  end

  private

    def set_user
      @user = Current.user
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :time_zone, :preferred_size, :preferred_code_style, :preferred_font, :preferred_theme, :preferred_font_size)
    end


end
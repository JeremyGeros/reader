class UsersController < ApplicationController
  before_action :require_user
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :set_page, only: [:edit, :update]

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to settings_path(page: @page), notice: 'User was successfully updated.' }
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
      format.html { redirect_to root_url, notice: 'Account deleted.' }
    end
  end

  private

    def set_user
      @user = Current.user
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :time_zone, :preferred_size, :preferred_code_style, :preferred_font, :preferred_theme, :preferred_font_size, :sidebar_collapsed)
    end

    def set_page
      if ['appearance', 'account'].include?(params[:page])
        @page = params[:page]
      else
        @page = 'account'
      end
    end


end
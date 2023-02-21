module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
    before_action :require_user
  end

  private
    def authenticate
      if authenticated_user = UserSession.find_by(key: session[:session_key])&.user
        Current.user = authenticated_user

        if Current.user.admin? && session[:admin_login_as].present?
          Current.user = User.find(session[:admin_login_as])
        end
      end
    end

    def verify_and_login!(email, password)
      email = email.strip.downcase

      user = User.find_by_email(email)

      return false unless user
      return false unless user.authenticate(password)

      login_user!(user)
    end

    def login_user!(user)
      user_session = user.user_sessions.create!

      raise ActiveRecord::RecordNotFound unless user_session.key.present?

      session[:session_key] = user_session.key
      true
    end

    def logout!
      user_session = UserSession.find_by(key: session[:session_key])
      raise ActiveRecord::RecordNotFound unless user_session.user == Current.user
      user_session.destroy!
      session[:session_key] = nil
      true
    end

    def require_user
      redirect_to signup_url unless Current.user
    end

    def require_no_user
      redirect_to root_url if Current.user
    end
end
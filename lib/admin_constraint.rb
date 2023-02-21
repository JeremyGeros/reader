class AdminConstraint
  def matches?(request)
    return false unless request.session[:session_key]
    user = UserSession.find_by(key: request.session[:session_key])&.user
    user && user.admin?
  end
end
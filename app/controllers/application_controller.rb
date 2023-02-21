class ApplicationController < ActionController::Base
  
  include Authentication
  include SetCurrentRequestDetails
  include Pagy::Backend
  
  before_action :set_active_storage_current_host
  
  def set_active_storage_current_host
    ActiveStorage::Current.host = request.base_url
  end
end

class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    "Michael Scott"
  end
end

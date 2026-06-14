class DashboardController < ApplicationController
  before_action :require_login

  def index
    @user = current_user
  end

  private

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Debes iniciar sesión para acceder al dashboard."
    end
  end
end

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def admin?
    current_user&.role == "admin"
  end

  def authenticate_user!
    unless logged_in?
      redirect_to login_path, alert: "Debe iniciar sesión para acceder."
    end
  end

  def authenticate_admin!
    unless admin?
      redirect_to root_path, alert: "No tiene permisos para acceder a esta sección."
    end
  end
end

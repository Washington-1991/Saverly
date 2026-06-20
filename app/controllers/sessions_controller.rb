class SessionsController < ApplicationController
  def new
  end

  def create
    # Permitir tanto el nuevo parámetro "login" como el antiguo "username" (por si quedan referencias)
    login = params[:login] || params[:username]
    if login.blank?
      flash.now[:alert] = "Debe ingresar su email o nombre de usuario"
      render :new, status: :unprocessable_entity and return
    end

    # Buscar usuario por email normalizado primero, luego por username exacto
    user = User.find_by(email: login.downcase.strip) || User.find_by(username: login)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Bienvenido, #{user.username}."
    else
      flash.now[:alert] = "Email/Usuario o contraseña inválidos"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Sesión cerrada."
  end
end

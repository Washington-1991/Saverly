class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :edit, :update, :destroy ]

  def index
    @users = User.order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "Usuario creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Si el campo password está en blanco, no se actualiza la contraseña
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Usuario actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # No permitir que un admin se elimine a sí mismo
    if @user == current_user
      redirect_to admin_users_path, alert: "No puedes eliminar tu propio usuario."
      return
    end

    @user.destroy
    redirect_to admin_users_path, notice: "Usuario eliminado."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :role)
  end
end

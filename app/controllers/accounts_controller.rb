class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [ :edit, :update, :destroy ]

  def index
    @accounts = current_user.accounts.order(:name)
  end

  def new
    @account = current_user.accounts.build
  end

  def create
    @account = current_user.accounts.build(account_params)
    if @account.save
      redirect_to accounts_path, notice: "Cuenta creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @account ya está cargado por before_action
  end

  def update
    if @account.update(account_params)
      redirect_to accounts_path, notice: "Cuenta actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @account.movements_as_source.exists? || @account.movements_as_destination.exists?
      redirect_to accounts_path, alert: "No se puede eliminar una cuenta con movimientos asociados."
    else
      @account.destroy
      redirect_to accounts_path, notice: "Cuenta eliminada."
    end
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:id])
  end

  def account_params
  params.require(:account).permit(:name, :current_balance)
end
end

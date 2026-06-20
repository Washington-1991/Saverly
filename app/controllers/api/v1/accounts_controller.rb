class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [ :edit, :update, :destroy ]

  # GET /accounts
  def index
    @accounts = current_user.accounts.order(:name)
  end

  # GET /accounts/new
  def new
    @account = current_user.accounts.build
  end

  # POST /accounts
  def create
    @account = current_user.accounts.build(account_params)

    if @account.save
      redirect_to accounts_path, notice: "Cuenta creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /accounts/:id/edit
  def edit
    # @account ya está cargado por before_action
  end

  # PATCH/PUT /accounts/:id
  def update
    if @account.update(account_params)
      redirect_to accounts_path, notice: "Cuenta actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/:id
  def destroy
    # Verificar si la cuenta tiene movimientos asociados
    if @account.movements_as_origin.exists? || @account.movements_as_destination.exists?
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
    params.require(:account).permit(:name, :kind, :current_balance)
    # Si el campo en la base de datos se llama 'balance' en lugar de 'current_balance',
    # cámbialo a :balance. Pero según tu API usas current_balance.
  end
end

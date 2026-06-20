class MovementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movement, only: [ :edit, :update, :destroy ] # opcional para editar/eliminar

  # GET /movements
  def index
    @movements = current_user.movements
                             .includes(:source_account, :destination_account)
                             .order(date: :desc)
                             .limit(50)
  end

  # GET /movements/new
  def new
    @movement = Movement.new
    # Solo mostramos cuentas de activo (asset) como origen/destino
    @accounts = current_user.accounts.where(kind: "asset").order(:name)
  end

  # POST /movements
  def create
    @movement = current_user.movements.build(movement_params)

    if @movement.save
      redirect_to movements_path, notice: "Movimiento registrado correctamente."
    else
      @accounts = current_user.accounts.where(kind: "asset").order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /movements/:id/edit (opcional)
  def edit
    # @movement ya está cargado por before_action
    @accounts = current_user.accounts.where(kind: "asset").order(:name)
  end

  # PATCH/PUT /movements/:id (opcional)
  def update
    if @movement.update(movement_params)
      redirect_to movements_path, notice: "Movimiento actualizado correctamente."
    else
      @accounts = current_user.accounts.where(kind: "asset").order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /movements/:id (opcional)
  def destroy
    @movement.destroy
    redirect_to movements_path, notice: "Movimiento eliminado."
  end

  private

  def set_movement
    @movement = current_user.movements.find(params[:id])
  end

  def movement_params
    params.require(:movement).permit(:date, :description, :amount, :source_account_id, :destination_account_id)
  end
end

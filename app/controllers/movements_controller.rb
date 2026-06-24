class MovementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movement, only: [ :edit, :update, :destroy, :show ]

  def index
    movements = current_user.movements.includes(:source_account, :destination_account)

    # Filtros por tipo
    if params[:movement_type].present?
      movements = movements.where(movement_type: params[:movement_type])
    end

    # Filtro por fecha desde
    if params[:date_from].present?
      movements = movements.where("date >= ?", params[:date_from])
    end

    # Filtro por fecha hasta
    if params[:date_to].present?
      movements = movements.where("date <= ?", params[:date_to])
    end

    @movements = movements.order(date: :desc, created_at: :desc)
  end

  def show
    # @movement ya está cargado por set_movement
  end

  def new
    @movement = Movement.new
    @accounts = current_user.accounts.order(:name)
  end

  def edit
    @accounts = current_user.accounts.order(:name)
  end

  def create
    @movement = current_user.movements.build(movement_params)
    if @movement.save
      redirect_to movements_path, notice: "Movimiento registrado correctamente."
    else
      @accounts = current_user.accounts.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @movement.update(movement_params)
      redirect_to movements_path, notice: "Movimiento actualizado correctamente."
    else
      @accounts = current_user.accounts.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @movement.destroy
    redirect_to movements_path, notice: "Movimiento eliminado correctamente."
  end

  private

  def set_movement
    @movement = current_user.movements.find(params[:id])
  end

  def movement_params
    params.require(:movement).permit(:date, :description, :amount, :movement_type,
                                     :source_account_id, :destination_account_id)
  end
end

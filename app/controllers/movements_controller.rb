class MovementsController < ApplicationController
  before_action :authenticate_user!

  def index
    @movements = current_user.movements
                             .includes(:source_account, :destination_account)
                             .order(date: :desc)
                             .limit(50)
  end

  def new
    @movement = Movement.new
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

  private

  def movement_params
    params.require(:movement).permit(:date, :description, :amount, :movement_type,
                                     :source_account_id, :destination_account_id)
  end
end

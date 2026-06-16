module Api
  module V1
    class MovementsController < BaseController
      def index
        @movements = current_user.movements
                                 .includes(:source_account, :destination_account)
                                 .order(date: :desc)
        render json: @movements, include: { source_account: { only: :name }, destination_account: { only: :name } }
      end

      def create
        @movement = current_user.movements.build(movement_params)
        if @movement.save
          render json: @movement, status: :created, include: { source_account: { only: :name }, destination_account: { only: :name } }
        else
          render json: { errors: @movement.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        @movement = current_user.movements.find(params[:id])
        render json: @movement, include: { source_account: { only: :name }, destination_account: { only: :name } }
      end

      def update
        @movement = current_user.movements.find(params[:id])
        if @movement.update(movement_params)
          render json: @movement, include: { source_account: { only: :name }, destination_account: { only: :name } }
        else
          render json: { errors: @movement.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @movement = current_user.movements.find(params[:id])
        @movement.destroy
        head :no_content
      end

      private

      def movement_params
        params.require(:movement).permit(:date, :description, :amount, :source_account_id, :destination_account_id)
      end
    end
  end
end

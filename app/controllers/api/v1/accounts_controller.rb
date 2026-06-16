module Api
  module V1
    class AccountsController < BaseController
      def index
        @accounts = current_user.accounts
        render json: @accounts, only: [ :id, :name, :kind, :current_balance ]
      end

      def create
        @account = current_user.accounts.build(account_params)
        if @account.save
          render json: @account, status: :created, only: [ :id, :name, :kind, :current_balance ]
        else
          render json: { errors: @account.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        @account = current_user.accounts.find(params[:id])
        render json: @account, only: [ :id, :name, :kind, :current_balance ]
      end

      def update
        @account = current_user.accounts.find(params[:id])
        if @account.update(account_params)
          render json: @account, only: [ :id, :name, :kind, :current_balance ]
        else
          render json: { errors: @account.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @account = current_user.accounts.find(params[:id])
        if @account.destroy
          head :no_content
        else
          render json: { errors: @account.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def account_params
        params.require(:account).permit(:name, :kind)
      end
    end
  end
end

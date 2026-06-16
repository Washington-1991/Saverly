module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :require_login_api
      respond_to :json

      private

      def require_login_api
        unless current_user
          render json: { error: "No autenticado" }, status: :unauthorized
        end
      end
    end
  end
end

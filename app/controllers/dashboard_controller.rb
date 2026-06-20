class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @accounts = current_user.accounts.internal.order(:name)
    @recent_movements = current_user.movements
                                    .includes(:source_account, :destination_account)
                                    .order(date: :desc)
                                    .limit(10)
  end
end

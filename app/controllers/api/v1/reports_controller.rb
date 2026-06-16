module Api
  module V1
    class ReportsController < BaseController
      # GET /api/v1/reports/balance
      def balance
        cache_key = [ "reports", "balance", current_user.id, current_user.updated_at.to_i ]
        result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          asset_accounts = current_user.accounts.where(kind: "asset")
          total_balance = asset_accounts.sum(:current_balance)
          accounts_detail = asset_accounts.select(:id, :name, :current_balance)
          {
            total_balance: total_balance.to_f,
            accounts: accounts_detail.as_json(only: [ :id, :name ], methods: [ :balance ])
          }
        end
        render json: result
      end

      # GET /api/v1/reports/income_vs_expense
      def income_vs_expense
        start_date = params[:start_date]&.to_date || 1.month.ago.to_date
        end_date = params[:end_date]&.to_date || Date.today

        cache_key = [ "reports", "income_vs_expense", current_user.id, start_date, end_date ]
        result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          income_accounts = current_user.accounts.where(kind: "income")
          expense_accounts = current_user.accounts.where(kind: "expense")

          total_income = Movement.joins(:destination_account)
                                .where(user: current_user, destination_account: income_accounts, date: start_date..end_date)
                                .sum(:amount)

          total_expense = Movement.joins(:source_account)
                                 .where(user: current_user, source_account: expense_accounts, date: start_date..end_date)
                                 .sum(:amount)

          {
            start_date: start_date,
            end_date: end_date,
            total_income: total_income.to_f,
            total_expense: total_expense.to_f,
            net: (total_income - total_expense).to_f
          }
        end
        render json: result
      end

      # GET /api/v1/reports/recent_movements?limit=10
      def recent_movements
        limit = params[:limit]&.to_i || 10
        cache_key = [ "reports", "recent_movements", current_user.id, limit ]
        result = Rails.cache.fetch(cache_key, expires_in: 2.minutes) do
          movements = current_user.movements
                                  .includes(:source_account, :destination_account)
                                  .order(date: :desc, created_at: :desc)
                                  .limit(limit)
          movements.as_json(
            only: [ :id, :date, :amount, :description ],
            include: {
              source_account: { only: [ :id, :name, :kind ] },
              destination_account: { only: [ :id, :name, :kind ] }
            }
          )
        end
        render json: result
      end

      # GET /api/v1/reports/monthly_summary?year=2025&month=6
      def monthly_summary
        year = params[:year]&.to_i || Date.today.year
        month = params[:month]&.to_i || Date.today.month
        start_date = Date.new(year, month, 1)
        end_date = start_date.end_of_month

        cache_key = [ "reports", "monthly_summary", current_user.id, year, month ]
        result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          income_accounts = current_user.accounts.where(kind: "income")
          expense_accounts = current_user.accounts.where(kind: "expense")

          total_income = Movement.joins(:destination_account)
                                .where(user: current_user, destination_account: income_accounts, date: start_date..end_date)
                                .sum(:amount)

          total_expense = Movement.joins(:source_account)
                                 .where(user: current_user, source_account: expense_accounts, date: start_date..end_date)
                                 .sum(:amount)

          daily_movements = Movement.where(user: current_user, date: start_date..end_date)
                                    .group(:date)
                                    .select("date, SUM(amount) as total_amount, COUNT(*) as count")
                                    .order(:date)

          {
            year: year,
            month: month,
            start_date: start_date,
            end_date: end_date,
            total_income: total_income.to_f,
            total_expense: total_expense.to_f,
            net: (total_income - total_expense).to_f,
            daily_summary: daily_movements.map { |d| { date: d.date, total: d.total_amount.to_f, count: d.count } }
          }
        end
        render json: result
      end
    end
  end
end

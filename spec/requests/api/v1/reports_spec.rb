require 'swagger_helper'

RSpec.describe 'api/v1/reports', type: :request do
  path '/api/v1/reports/balance' do
    get 'Obtener balance general' do
      tags 'Reportes'
      produces 'application/json'
      security [ cookie: [] ]

      response '200', 'balance obtenido' do
        schema '$ref' => '#/components/schemas/BalanceReport'
        run_test!
      end
    end
  end

  path '/api/v1/reports/income_vs_expense' do
    get 'Ingresos vs gastos en un rango de fechas' do
      tags 'Reportes'
      produces 'application/json'
      security [ cookie: [] ]
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false

      response '200', 'reporte obtenido' do
        schema '$ref' => '#/components/schemas/IncomeExpenseReport'
        run_test!
      end
    end
  end

  path '/api/v1/reports/recent_movements' do
    get 'Movimientos recientes' do
      tags 'Reportes'
      produces 'application/json'
      security [ cookie: [] ]
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Número máximo de movimientos (default 10)'

      response '200', 'movimientos obtenidos' do
        schema '$ref' => '#/components/schemas/RecentMovementsReport'
        run_test!
      end
    end
  end

  path '/api/v1/reports/monthly_summary' do
    get 'Resumen mensual' do
      tags 'Reportes'
      produces 'application/json'
      security [ cookie: [] ]
      parameter name: :year, in: :query, type: :integer, required: false
      parameter name: :month, in: :query, type: :integer, required: false

      response '200', 'resumen obtenido' do
        schema '$ref' => '#/components/schemas/MonthlySummary'
        run_test!
      end
    end
  end
end

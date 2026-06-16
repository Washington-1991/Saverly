# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API de Saverly',
        version: 'v1',
        description: 'Documentación de la API para la aplicación de contabilidad personal Saverly'
      },
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Servidor de desarrollo'
        }
      ],
      components: {
        schemas: {
          Account: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              kind: { type: :string, enum: [ 'asset', 'expense', 'income' ] },
              current_balance: { type: :number, format: :float }
            }
          },
          Movement: {
            type: :object,
            properties: {
              id: { type: :integer },
              date: { type: :string, format: :date },
              amount: { type: :number, format: :float },
              description: { type: :string },
              source_account_id: { type: :integer },
              destination_account_id: { type: :integer }
            }
          },
          BalanceReport: {
            type: :object,
            properties: {
              total_balance: { type: :number, format: :float },
              accounts: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string },
                    balance: { type: :number, format: :float }
                  }
                }
              }
            }
          },
          IncomeExpenseReport: {
            type: :object,
            properties: {
              start_date: { type: :string, format: :date },
              end_date: { type: :string, format: :date },
              total_income: { type: :number, format: :float },
              total_expense: { type: :number, format: :float },
              net: { type: :number, format: :float }
            }
          },
          RecentMovementsReport: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                date: { type: :string, format: :date },
                amount: { type: :number, format: :float },
                description: { type: :string },
                source_account: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string },
                    kind: { type: :string }
                  }
                },
                destination_account: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string },
                    kind: { type: :string }
                  }
                }
              }
            }
          },
          MonthlySummary: {
            type: :object,
            properties: {
              year: { type: :integer },
              month: { type: :integer },
              start_date: { type: :string, format: :date },
              end_date: { type: :string, format: :date },
              total_income: { type: :number, format: :float },
              total_expense: { type: :number, format: :float },
              net: { type: :number, format: :float },
              daily_summary: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    date: { type: :string, format: :date },
                    total: { type: :number, format: :float },
                    count: { type: :integer }
                  }
                }
              }
            }
          }
        },
        securitySchemes: {
          cookie: {
            type: :apiKey,
            in: :cookie,
            name: '_saverly_session'
          }
        }
      },
      security: [ { cookie: [] } ]
    }
  }

  config.openapi_format = :yaml
end

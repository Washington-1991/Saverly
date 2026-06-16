require 'swagger_helper'

RSpec.describe 'api/v1/movements', type: :request do
  path '/api/v1/movements' do
    get 'Lista de movimientos' do
      tags 'Movimientos'
      produces 'application/json'
      security [ cookie: [] ]

      response '200', 'movimientos obtenidos' do
        schema type: :array, items: { '$ref' => '#/components/schemas/Movement' }
        run_test!
      end
    end

    post 'Crear un movimiento' do
      tags 'Movimientos'
      consumes 'application/json'
      produces 'application/json'
      security [ cookie: [] ]
      parameter name: :movement, in: :body, schema: {
        type: :object,
        properties: {
          date: { type: :string, format: :date },
          amount: { type: :number, format: :float },
          description: { type: :string },
          source_account_id: { type: :integer },
          destination_account_id: { type: :integer }
        },
        required: ['date', 'amount', 'source_account_id', 'destination_account_id']
      }

      response '201', 'movimiento creado' do
        schema '$ref' => '#/components/schemas/Movement'
        run_test!
      end

      response '422', 'datos inválidos' do
        run_test!
      end
    end
  end

  path '/api/v1/movements/{id}' do
    get 'Obtener un movimiento' do
      tags 'Movimientos'
      produces 'application/json'
      security [ cookie: [] ]
      parameter name: :id, in: :path, type: :integer

      response '200', 'movimiento encontrado' do
        schema '$ref' => '#/components/schemas/Movement'
        run_test!
      end
    end

    put 'Actualizar un movimiento' do
      tags 'Movimientos'
      consumes 'application/json'
      produces 'application/json'
      security [ cookie: [] ]
      parameter name: :id, in: :path, type: :integer
      parameter name: :movement, in: :body, schema: {
        type: :object,
        properties: {
          date: { type: :string, format: :date },
          amount: { type: :number, format: :float },
          description: { type: :string },
          source_account_id: { type: :integer },
          destination_account_id: { type: :integer }
        }
      }

      response '200', 'movimiento actualizado' do
        schema '$ref' => '#/components/schemas/Movement'
        run_test!
      end
    end

    delete 'Eliminar un movimiento' do
      tags 'Movimientos'
      security [ cookie: [] ]
      parameter name: :id, in: :path, type: :integer

      response '204', 'movimiento eliminado' do
        run_test!
      end
    end
  end
end

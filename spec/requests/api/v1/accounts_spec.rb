require 'swagger_helper'

RSpec.describe 'api/v1/accounts', type: :request do
  path '/api/v1/accounts' do
    get 'Lista de cuentas del usuario' do
      tags 'Cuentas'
      produces 'application/json'
      security [ cookie: [] ]

      response '200', 'cuentas obtenidas' do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        run_test!
      end
    end

    post 'Crear una cuenta' do
      tags 'Cuentas'
      consumes 'application/json'
      produces 'application/json'
      security [ cookie: [] ]
      parameter name: :account, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          kind: { type: :string, enum: ['asset', 'expense', 'income'] }
        },
        required: ['name', 'kind']
      }

      response '201', 'cuenta creada' do
        schema '$ref' => '#/components/schemas/Account'
        run_test!
      end

      response '422', 'datos inválidos' do
        schema type: :object,
          properties: {
            errors: { type: :array, items: { type: :string } }
          }
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}' do
    get 'Obtener una cuenta' do
      tags 'Cuentas'
      produces 'application/json'
      security [ cookie: [] ]
      parameter name: :id, in: :path, type: :integer

      response '200', 'cuenta encontrada' do
        schema '$ref' => '#/components/schemas/Account'
        run_test!
      end

      response '404', 'cuenta no encontrada' do
        run_test!
      end
    end

    put 'Actualizar una cuenta' do
      tags 'Cuentas'
      consumes 'application/json'
      produces 'application/json'
      security [ cookie: [] ]
      parameter name: :id, in: :path, type: :integer
      parameter name: :account, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          kind: { type: :string, enum: ['asset', 'expense', 'income'] }
        }
      }

      response '200', 'cuenta actualizada' do
        schema '$ref' => '#/components/schemas/Account'
        run_test!
      end

      response '422', 'datos inválidos' do
        run_test!
      end
    end

    delete 'Eliminar una cuenta' do
      tags 'Cuentas'
      security [ cookie: [] ]
      parameter name: :id, in: :path, type: :integer

      response '204', 'cuenta eliminada' do
        run_test!
      end

      response '422', 'no se puede eliminar porque tiene movimientos asociados' do
        run_test!
      end
    end
  end
end

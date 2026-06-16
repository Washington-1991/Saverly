class AddCurrentBalanceToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :current_balance, :decimal, precision: 12, scale: 2, default: 0.0, null: false
    # Añadimos un índice opcional para búsquedas por saldo (no obligatorio)
    add_index :accounts, :current_balance
  end
end

class AddExternalToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :external, :boolean, default: false, null: false
    add_index :accounts, :external
  end
end

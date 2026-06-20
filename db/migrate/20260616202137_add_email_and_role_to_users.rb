class AddEmailAndRoleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email, :string, null: false
    add_column :users, :role, :string, null: false, default: 'user'
    add_index :users, :email, unique: true
  end
end

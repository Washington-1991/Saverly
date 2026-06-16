class AddUniqueIndexToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_index :accounts, [ :user_id, :name ], unique: true
  end
end

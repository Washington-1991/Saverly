class RemoveKindFromAccounts < ActiveRecord::Migration[7.2]
  def change
    remove_column :accounts, :kind, :string
  end
end

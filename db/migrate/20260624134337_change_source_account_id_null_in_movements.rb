class ChangeSourceAccountIdNullInMovements < ActiveRecord::Migration[7.2]
  def change
    change_column_null :movements, :source_account_id, true
  end
end

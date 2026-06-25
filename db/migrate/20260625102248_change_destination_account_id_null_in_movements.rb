class ChangeDestinationAccountIdNullInMovements < ActiveRecord::Migration[7.2]
  def change
    change_column_null :movements, :destination_account_id, true
  end
end

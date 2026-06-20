class AddMovementTypeToMovements < ActiveRecord::Migration[7.2]
  def change
    add_column :movements, :movement_type, :string
  end
end

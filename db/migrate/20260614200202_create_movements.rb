class CreateMovements < ActiveRecord::Migration[7.2]
  def change
    create_table :movements do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.string :description
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.references :source_account, null: false, foreign_key: { to_table: :accounts }
      t.references :destination_account, null: false, foreign_key: { to_table: :accounts }

      t.timestamps
    end

    add_index :movements, [ :user_id, :date ]
  end
end

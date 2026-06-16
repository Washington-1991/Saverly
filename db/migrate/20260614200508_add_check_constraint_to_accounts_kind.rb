class AddCheckConstraintToAccountsKind < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      ALTER TABLE accounts
      ADD CONSTRAINT check_accounts_kind
      CHECK (kind IN ('asset', 'expense', 'income'))
    SQL
  end

  def down
    execute "ALTER TABLE accounts DROP CONSTRAINT check_accounts_kind"
  end
end

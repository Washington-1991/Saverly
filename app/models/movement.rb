class Movement < ApplicationRecord
  belongs_to :user
  belongs_to :source_account, class_name: "Account"
  belongs_to :destination_account, class_name: "Account"

  validates :date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :different_accounts
  validate :accounts_belong_to_user
  validate :user_owns_accounts
  validate :sufficient_balance, if: :source_account_asset?
  validate :income_account_only_as_destination
  validate :expense_account_only_as_source

  after_create :update_balances_on_create
  after_destroy :update_balances_on_destroy
  after_update :update_balances_on_update

  # Invalidar caché de reportes al guardar o eliminar
  after_save :expire_reports_cache
  after_destroy :expire_reports_cache

  private

  def different_accounts
    return unless source_account_id == destination_account_id
    errors.add(:base, "La cuenta origen y destino no pueden ser la misma")
  end

  def accounts_belong_to_user
    return unless source_account && destination_account
    unless source_account.user_id == user_id && destination_account.user_id == user_id
      errors.add(:base, "Ambas cuentas deben pertenecer al mismo usuario")
    end
  end

  def user_owns_accounts
    return unless source_account && destination_account && user
    unless source_account.user_id == user.id && destination_account.user_id == user.id
      errors.add(:base, "El usuario no es propietario de una o ambas cuentas")
    end
  end

  def source_account_asset?
    source_account&.asset?
  end

  def sufficient_balance
    return unless source_account_asset? && amount.present?
    if source_account.current_balance < amount
      errors.add(:base, "Saldo insuficiente en la cuenta origen (#{source_account.name})")
    end
  end

  def income_account_only_as_destination
    return unless source_account&.income?
    errors.add(:source_account, "no puede ser una cuenta de ingreso (income). Las cuentas de ingreso solo pueden ser destino.")
  end

  def expense_account_only_as_source
    return unless destination_account&.expense?
    errors.add(:destination_account, "no puede ser una cuenta de gasto (expense). Las cuentas de gasto solo pueden ser origen.")
  end

  def expire_reports_cache
    Rails.cache.delete_matched(/reports.*user:#{user_id}/)
  end

  def update_balances_on_create
    Movement.transaction do
      source_account.lock!
      destination_account.lock!

      if source_account.asset?
        source_account.update!(current_balance: source_account.current_balance - amount)
      end
      if destination_account.asset?
        destination_account.update!(current_balance: destination_account.current_balance + amount)
      end
    end
  end

  def update_balances_on_destroy
    Movement.transaction do
      source_account.lock!
      destination_account.lock!

      if source_account.asset?
        source_account.update!(current_balance: source_account.current_balance + amount)
      end
      if destination_account.asset?
        destination_account.update!(current_balance: destination_account.current_balance - amount)
      end
    end
  end

  def update_balances_on_update
    return unless saved_change_to_amount? || saved_change_to_source_account_id? || saved_change_to_destination_account_id?

    Movement.transaction do
      old_source_id = source_account_id_before_last_save
      old_dest_id = destination_account_id_before_last_save
      old_amount = amount_before_last_save

      revert_old_movement(old_source_id, old_dest_id, old_amount)
      apply_new_movement
    end
  end

  def revert_old_movement(old_source_id, old_dest_id, old_amount)
    return unless old_source_id && old_dest_id && old_amount

    old_source = Account.find(old_source_id)
    old_dest = Account.find(old_dest_id)

    old_source.lock!
    old_dest.lock!

    if old_source.asset?
      old_source.update!(current_balance: old_source.current_balance + old_amount)
    end
    if old_dest.asset?
      old_dest.update!(current_balance: old_dest.current_balance - old_amount)
    end
  end

  def apply_new_movement
    source_account.lock!
    destination_account.lock!

    if source_account.asset?
      source_account.update!(current_balance: source_account.current_balance - amount)
    end
    if destination_account.asset?
      destination_account.update!(current_balance: destination_account.current_balance + amount)
    end
  end
end

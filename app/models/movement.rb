class Movement < ApplicationRecord
  belongs_to :user
  belongs_to :source_account, class_name: "Account", optional: true
  belongs_to :destination_account, class_name: "Account", optional: true

  MOVEMENT_TYPES = %w[transfer income expense].freeze

  validates :date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :movement_type, presence: true, inclusion: { in: MOVEMENT_TYPES }
  validate :different_accounts, if: -> { source_account_id && destination_account_id }
  validate :user_owns_accounts
  validate :at_least_one_account
  validate :sufficient_balance, if: -> { source_account && source_account.internal? }

  after_create :update_balances_on_create
  after_destroy :update_balances_on_destroy
  after_update :update_balances_on_update

  private

  def different_accounts
    if source_account_id == destination_account_id
      errors.add(:base, "La cuenta origen y destino no pueden ser la misma")
    end
  end

  def user_owns_accounts
    if source_account && source_account.user_id != user.id
      errors.add(:source_account, "no pertenece al usuario")
    end
    if destination_account && destination_account.user_id != user.id
      errors.add(:destination_account, "no pertenece al usuario")
    end
  end

  def at_least_one_account
    if source_account_id.nil? && destination_account_id.nil?
      errors.add(:base, "Debe seleccionar al menos una cuenta")
    end
  end

  def sufficient_balance
    if source_account && source_account.current_balance < amount
      errors.add(:base, "Saldo insuficiente en la cuenta origen (#{source_account.name})")
    end
  end

  # ─── Actualización de saldos ───
  # Siempre: restar de origen, sumar a destino (si existen y no son externas)

  def update_balances_on_create
    Movement.transaction do
      if source_account && !source_account.external?
        source_account.adjust_balance!(-amount)
      end
      if destination_account && !destination_account.external?
        destination_account.adjust_balance!(amount)
      end
    end
  end

  def update_balances_on_destroy
    Movement.transaction do
      if source_account && !source_account.external?
        source_account.adjust_balance!(amount)
      end
      if destination_account && !destination_account.external?
        destination_account.adjust_balance!(-amount)
      end
    end
  end

  def update_balances_on_update
    return unless saved_change_to_amount? || saved_change_to_source_account_id? ||
                  saved_change_to_destination_account_id? || saved_change_to_movement_type?

    Movement.transaction do
      # Revertir el movimiento anterior
      old_source_id = source_account_id_before_last_save
      old_dest_id = destination_account_id_before_last_save
      old_amount = amount_before_last_save

      if old_source_id
        old_source = Account.find(old_source_id)
        if !old_source.external?
          old_source.adjust_balance!(old_amount)
        end
      end
      if old_dest_id
        old_dest = Account.find(old_dest_id)
        if !old_dest.external?
          old_dest.adjust_balance!(-old_amount)
        end
      end

      # Aplicar el nuevo movimiento
      if source_account && !source_account.external?
        source_account.adjust_balance!(-amount)
      end
      if destination_account && !destination_account.external?
        destination_account.adjust_balance!(amount)
      end
    end
  end
end

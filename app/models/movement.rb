class Movement < ApplicationRecord
  belongs_to :user
  belongs_to :source_account, class_name: "Account", optional: true
  belongs_to :destination_account, class_name: "Account", optional: true

  MOVEMENT_TYPES = %w[transfer income expense].freeze

  validates :date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :movement_type, presence: true, inclusion: { in: MOVEMENT_TYPES }

  # Validaciones específicas según el tipo de movimiento
  validate :required_accounts_by_type
  validate :different_accounts, if: -> { source_account_id && destination_account_id }
  validate :user_owns_accounts
  validate :sufficient_balance, if: -> { source_account && source_account.internal? }

  after_create :update_balances_on_create
  after_destroy :update_balances_on_destroy
  after_update :update_balances_on_update

  private

  # --- Validación de cuentas requeridas según el tipo ---
  def required_accounts_by_type
    case movement_type
    when "income"
      if destination_account_id.blank?
        errors.add(:destination_account, "debe estar presente para un ingreso")
      end
      if source_account_id.present?
        errors.add(:source_account, "no debe estar presente para un ingreso (el dinero viene de fuera)")
      end
    when "expense"
      if source_account_id.blank?
        errors.add(:source_account, "debe estar presente para un gasto")
      end
      if destination_account_id.present?
        errors.add(:destination_account, "no debe estar presente para un gasto (el dinero sale hacia fuera)")
      end
    when "transfer"
      if source_account_id.blank?
        errors.add(:source_account, "debe estar presente para una transferencia")
      end
      if destination_account_id.blank?
        errors.add(:destination_account, "debe estar presente para una transferencia")
      end
    end
  end

  # --- Validación de que origen y destino no sean la misma ---
  def different_accounts
    if source_account_id == destination_account_id
      errors.add(:base, "La cuenta origen y destino no pueden ser la misma")
    end
  end

  # --- Validación de pertenencia al usuario ---
  def user_owns_accounts
    if source_account && source_account.user_id != user.id
      errors.add(:source_account, "no pertenece al usuario")
    end
    if destination_account && destination_account.user_id != user.id
      errors.add(:destination_account, "no pertenece al usuario")
    end
  end

  # --- Validación de saldo suficiente (con soporte para edición) ---
  def sufficient_balance
    return unless source_account && source_account.internal?

    # Para actualizaciones, el saldo actual de la cuenta YA incluye este movimiento.
    # Por tanto, calculamos el saldo antes del movimiento para hacer la comprobación.
    if persisted?
      # amount_was es el valor anterior del importe (si cambió, o el mismo si no)
      balance_before = source_account.current_balance + (amount_was || 0)
    else
      balance_before = source_account.current_balance
    end

    if balance_before < amount
      errors.add(:base, "Saldo insuficiente en la cuenta origen (#{source_account.name}). Disponible: #{balance_before}")
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

class Account < ApplicationRecord
  belongs_to :user
  has_many :movements_as_source, class_name: "Movement", foreign_key: "source_account_id", dependent: :restrict_with_error
  has_many :movements_as_destination, class_name: "Movement", foreign_key: "destination_account_id", dependent: :restrict_with_error

  KINDS = %w[asset expense income].freeze

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :current_balance, numericality: true

  # Saldo actual (lectura directa del campo cacheado)
  def balance
    current_balance
  end

  # Método interno para incrementar/decrementar saldo con bloqueo pesimista
  def adjust_balance!(amount)
    with_lock do
      update!(current_balance: current_balance + amount)
    end
  end

  # Verificar si la cuenta es de tipo asset
  def asset?
    kind == "asset"
  end

  # Verificar si la cuenta es de tipo income
  def income?
    kind == "income"
  end

  # Verificar si la cuenta es de tipo expense
  def expense?
    kind == "expense"
  end

  # Método de seguridad para verificar propiedad
  def owned_by?(user)
    self.user_id == user.id
  end

  # Método de recálculo completo (útil para migraciones o correcciones)
  def recalc_balance!
    new_balance = movements_as_destination.sum(:amount) - movements_as_source.sum(:amount)
    update!(current_balance: new_balance)
  end
end

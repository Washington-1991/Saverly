class Account < ApplicationRecord
  belongs_to :user
  has_many :movements_as_source, class_name: "Movement", foreign_key: "source_account_id", dependent: :restrict_with_error
  has_many :movements_as_destination, class_name: "Movement", foreign_key: "destination_account_id", dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :current_balance, numericality: true

  # Scopes para filtrar cuentas externas
  scope :external, -> { where(external: true) }
  scope :internal, -> { where(external: false) }

  def adjust_balance!(amount)
    with_lock do
      update!(current_balance: current_balance + amount)
    end
  end

  def owned_by?(user)
    self.user_id == user.id
  end

  def recalc_balance!
    new_balance = movements_as_destination.sum(:amount) - movements_as_source.sum(:amount)
    update!(current_balance: new_balance)
  end

  def external?
    external == true
  end
end

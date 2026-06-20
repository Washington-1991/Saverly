class User < ApplicationRecord
  has_secure_password

  before_save :downcase_email

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "debe ser un email válido" }
  validates :role, presence: true, inclusion: { in: %w[admin user], message: "%{value} no es un rol válido" }

  has_many :accounts, dependent: :destroy
  has_many :movements, dependent: :destroy

  after_create :create_external_account

  private

  def downcase_email
    self.email = email.downcase.strip if email.present?
  end

  def create_external_account
    accounts.find_or_create_by(name: "Externo", current_balance: 0, external: true)
  end
end

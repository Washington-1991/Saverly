class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true

  has_many :accounts, dependent: :destroy
  has_many :movements, dependent: :destroy
end

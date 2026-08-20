class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 7 }

  has_many :reviews
  has_many :book_votes, dependent: :destroy
  has_many :review_votes, dependent: :destroy
end

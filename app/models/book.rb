class Book < ApplicationRecord
  belongs_to :author
  has_many :reviews
  has_many :book_votes, dependent: :destroy

  validates :title, presence: true
end

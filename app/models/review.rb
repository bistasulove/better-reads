class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book
  has_many :review_votes, dependent: :destroy

  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
end

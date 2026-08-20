class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book
  has_many :review_votes, dependent: :destroy

  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  def score
    review_votes.sum(:value)
  end

  def vote_by(user)
    review_votes.find_by(user: user)
  end

  def cast_vote!(user, value)
    vote = review_votes.find_or_initialize_by(user: user)
    vote.value = value
    vote.save!
  end

  def remove_vote!(user)
    review_votes.where(user: user).delete_all
  end
end

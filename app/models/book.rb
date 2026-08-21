class Book < ApplicationRecord
  belongs_to :author
  has_many :reviews, dependent: :destroy
  has_many :book_votes, dependent: :destroy

  validates :title, presence: true

  def score
    book_votes.sum(:value)
  end

  def vote_by(user)
    book_votes.find_by(user: user)
  end

  def cast_vote!(user, value)
    vote = book_votes.find_or_initialize_by(user: user)
    vote.value = value
    vote.save!
  end

  def remove_vote!(user)
    book_votes.where(user: user).delete_all
  end
end

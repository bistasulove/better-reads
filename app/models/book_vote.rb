class BookVote < ApplicationRecord
  belongs_to :user
  belongs_to :book
  
  validates :value, inclusion: { in: [1, -1], message: "must be 1 for upvote or -1 for downvote" }
  validates :user_id, uniqueness: { scope: :book_id, message: "has already voted on this book" }
end

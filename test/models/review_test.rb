require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  # review_votes.review_id has a real foreign key, so without dependent: on the
  # association the database refuses this delete and the Delete button in
  # reviews/index.html.erb raises. This test pins that behaviour.
  test "a review with votes can be destroyed" do
    review = reviews(:two)
    ReviewVote.create!(user: users(:austin), review: review, value: 1)

    assert_difference -> { ReviewVote.count }, -1 do
      assert_nothing_raised { review.destroy }
    end
  end
end

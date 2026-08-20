require "test_helper"

class ReviewVotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:austin)
    # Review "two" has no votes in the fixtures.
    @review = reviews(:two)
    post session_path, params: { email: @user.email, password: "betterreads" }
  end

  test "casting a vote on a review creates a row" do
    assert_difference("ReviewVote.count", 1) do
      post review_vote_path(@review), params: { value: 1 }
    end

    assert_equal 1, @review.vote_by(@user).value
  end

  test "voting the other way flips the existing row instead of adding one" do
    post review_vote_path(@review), params: { value: 1 }

    assert_no_difference("ReviewVote.count") do
      post review_vote_path(@review), params: { value: -1 }
    end

    assert_equal(-1, @review.vote_by(@user).value)
  end

  test "deleting removes the user's vote" do
    review = reviews(:three)

    assert_difference("ReviewVote.count", -1) do
      delete review_vote_path(review)
    end

    assert_nil review.vote_by(@user)
  end

  test "an invalid value is rejected without creating a vote" do
    assert_no_difference("ReviewVote.count") do
      post review_vote_path(@review), params: { value: 0 }
    end

    assert_equal "That is not a valid vote.", flash[:alert]
  end

  test "voting requires a logged in user" do
    delete session_path

    assert_no_difference("ReviewVote.count") do
      post review_vote_path(@review), params: { value: 1 }
    end

    assert_redirected_to new_session_path
  end
end

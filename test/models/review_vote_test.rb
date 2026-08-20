require "test_helper"

class ReviewVoteTest < ActiveSupport::TestCase
  # Review "two" has no votes in the fixtures, so austin is free to vote on it.
  def new_vote(attributes = {})
    ReviewVote.new({ user: users(:austin), review: reviews(:two), value: 1 }.merge(attributes))
  end

  test "an upvote is valid" do
    assert new_vote(value: 1).valid?
  end

  test "a downvote is valid" do
    assert new_vote(value: -1).valid?
  end

  test "value cannot be a number other than 1 or -1" do
    vote = new_vote(value: 5)

    assert_not vote.valid?
    assert_includes vote.errors[:value], "must be 1 for upvote or -1 for downvote"
  end

  test "value cannot be blank" do
    vote = new_vote(value: nil)

    assert_not vote.valid?
    assert_includes vote.errors[:value], "must be 1 for upvote or -1 for downvote"
  end

  test "a vote requires a user" do
    vote = new_vote(user: nil)

    assert_not vote.valid?
    assert_includes vote.errors[:user], "must exist"
  end

  test "a vote requires a review" do
    vote = new_vote(review: nil)

    assert_not vote.valid?
    assert_includes vote.errors[:review], "must exist"
  end

  # This is the test that would have caught scoping the uniqueness rule to
  # :book_id, which review_votes has no column for.
  test "a user cannot vote twice on the same review" do
    existing = review_votes(:bri_upvotes_review_one)
    duplicate = ReviewVote.new(user: existing.user, review: existing.review, value: -1)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already voted on this review"
  end

  test "a user can vote on more than one review" do
    assert_equal reviews(:one), review_votes(:bri_upvotes_review_one).review

    assert ReviewVote.new(user: users(:bri), review: reviews(:two), value: 1).valid?
  end

  test "a user can vote on their own review" do
    assert_equal users(:austin), reviews(:two).user

    assert new_vote(user: users(:austin), review: reviews(:two)).valid?
  end

  test "the database rejects a duplicate vote even without validations" do
    existing = review_votes(:bri_upvotes_review_one)
    duplicate = ReviewVote.new(user: existing.user, review: existing.review, value: -1)

    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save(validate: false) }
  end

  test "the database rejects an out of range value even without validations" do
    assert_raises(ActiveRecord::StatementInvalid) { new_vote(value: 5).save(validate: false) }
  end
end

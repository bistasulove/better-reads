require "test_helper"

class BookVoteTest < ActiveSupport::TestCase
  # bri has only voted on book "one" in the fixtures, so book "two" is free for
  # her to vote on without tripping the uniqueness rule.
  def new_vote(attributes = {})
    BookVote.new({ user: users(:bri), book: books(:two), value: 1 }.merge(attributes))
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

  test "value cannot be zero" do
    vote = new_vote(value: 0)

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

  test "a vote requires a book" do
    vote = new_vote(book: nil)

    assert_not vote.valid?
    assert_includes vote.errors[:book], "must exist"
  end

  test "a user cannot vote twice on the same book" do
    existing = book_votes(:austin_upvotes_gatsby)
    duplicate = BookVote.new(user: existing.user, book: existing.book, value: -1)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already voted on this book"
  end

  test "a user can vote on more than one book" do
    assert_equal books(:one), book_votes(:bri_upvotes_gatsby).book

    assert new_vote(book: books(:two)).valid?
  end

  test "two users can vote on the same book" do
    assert_equal books(:one), book_votes(:austin_upvotes_gatsby).book
    assert_equal books(:one), book_votes(:bri_upvotes_gatsby).book
  end

  # The two tests below bypass validations with save(validate: false) to prove
  # the database enforces these rules on its own. That matters because raw SQL,
  # insert_all, and update_column all skip the model layer entirely.
  test "the database rejects a duplicate vote even without validations" do
    existing = book_votes(:austin_upvotes_gatsby)
    duplicate = BookVote.new(user: existing.user, book: existing.book, value: -1)

    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save(validate: false) }
  end

  test "the database rejects an out of range value even without validations" do
    assert_raises(ActiveRecord::StatementInvalid) { new_vote(value: 5).save(validate: false) }
  end
end

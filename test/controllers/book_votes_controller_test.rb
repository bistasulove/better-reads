require "test_helper"

class BookVotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:austin)
    @book = books(:one)
    post session_path, params: { email: @user.email, password: "betterreads" }
  end

  test "casting a vote on a book the user has not voted on creates a row" do
    book = books(:two)
    book.book_votes.where(user: @user).delete_all

    assert_difference("BookVote.count", 1) do
      post book_vote_path(book), params: { value: 1 }
    end

    assert_equal 1, book.vote_by(@user).value
  end

  test "voting the other way flips the existing row instead of adding one" do
    assert_equal 1, @book.vote_by(@user).value

    assert_no_difference("BookVote.count") do
      post book_vote_path(@book), params: { value: -1 }
    end

    assert_equal(-1, @book.vote_by(@user).value)
  end

  test "deleting removes the user's vote" do
    assert_difference("BookVote.count", -1) do
      delete book_vote_path(@book)
    end

    assert_nil @book.vote_by(@user)
  end

  test "deleting only removes the current user's vote" do
    other_vote = book_votes(:bri_upvotes_gatsby)

    delete book_vote_path(@book)

    assert BookVote.exists?(other_vote.id)
  end

  test "an invalid value is rejected without creating a vote" do
    book = books(:two)
    book.book_votes.where(user: @user).delete_all

    assert_no_difference("BookVote.count") do
      post book_vote_path(book), params: { value: 5 }
    end

    assert_equal "That is not a valid vote.", flash[:alert]
  end

  test "a missing value is rejected without creating a vote" do
    book = books(:two)
    book.book_votes.where(user: @user).delete_all

    assert_no_difference("BookVote.count") do
      post book_vote_path(book)
    end
  end

  test "voting sends the user back where they came from" do
    post book_vote_path(@book), params: { value: -1 }, headers: { "HTTP_REFERER" => books_url }

    assert_redirected_to books_url
  end

  test "voting requires a logged in user" do
    delete session_path

    assert_no_difference("BookVote.count") do
      post book_vote_path(books(:two)), params: { value: 1 }
    end

    assert_redirected_to new_session_path
  end
end

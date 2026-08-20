require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "the user model validates password length" do
    user = User.new(email: "test@testing.com", password: "short")
    assert_not user.save
    assert_equal [:password], user.errors.as_json.keys

    user.password = "muchlongerpassword"
    assert user.save
  end

  # Same reasoning as the book test: fixture users have reviews, and Review has
  # no dependent: rule tying it to User, so this builds a user that only votes.
  test "destroying a user removes their votes" do
    user = User.create!(email: "voter@example.com", name: "Voter", password: "betterreads")
    BookVote.create!(user: user, book: books(:one), value: 1)
    ReviewVote.create!(user: user, review: reviews(:two), value: -1)

    assert_difference -> { BookVote.count + ReviewVote.count }, -2 do
      assert_nothing_raised { user.destroy }
    end
  end
end

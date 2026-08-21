require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "book model validates presence of required fields" do
    book = Book.new
    assert_not book.save
    assert_equal [:title, :author], book.errors.as_json.keys
  end

  test "book removes all linked reviews on destroy" do
    book = books(:one)

    reviews_count = book.reviews.count
    
    assert_difference("Review.count", -reviews_count) do
      book.destroy
    end
  end
end

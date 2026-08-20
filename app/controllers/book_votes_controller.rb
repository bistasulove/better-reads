class BookVotesController < ApplicationController
  before_action :set_book

  # POST /books/:book_id/vote
  def create
    value = vote_value

    if value.nil?
      redirect_back fallback_location: @book, alert: "That is not a valid vote."
    else
      @book.cast_vote!(current_user, value)
      redirect_back fallback_location: @book
    end
  end

  # DELETE /books/:book_id/vote
  def destroy
    @book.remove_vote!(current_user)
    redirect_back fallback_location: @book
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end

  # params arrive as strings from the browser and anyone can post anything,
  # so only 1 and -1 are allowed through. Returns nil for everything else.
  def vote_value
    value = params[:value].to_i
    value if [1, -1].include?(value)
  end
end

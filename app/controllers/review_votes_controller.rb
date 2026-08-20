class ReviewVotesController < ApplicationController
  before_action :set_review

  # POST /reviews/:review_id/vote
  def create
    value = vote_value

    if value.nil?
      redirect_back fallback_location: reviews_path, alert: "That is not a valid vote."
    else
      @review.cast_vote!(current_user, value)
      redirect_back fallback_location: reviews_path
    end
  end

  # DELETE /reviews/:review_id/vote
  def destroy
    @review.remove_vote!(current_user)
    redirect_back fallback_location: reviews_path
  end

  private

  def set_review
    @review = Review.find(params[:review_id])
  end

  # params arrive as strings from the browser and anyone can post anything,
  # so only 1 and -1 are allowed through. Returns nil for everything else.
  def vote_value
    value = params[:value].to_i
    value if [1, -1].include?(value)
  end
end

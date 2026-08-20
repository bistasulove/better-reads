class ReviewsController < ApplicationController
  def index
    @reviews = Review.all.limit(20)
    @review_scores = ReviewVote.where(review: @reviews).group(:review_id).sum(:value)
    @my_review_votes = ReviewVote.where(user: current_user, review: @reviews).pluck(:review_id, :value).to_h
  end

  def new
    @books = Book.all.limit(20)
    @review = Review.new
  end

  def create
    @review = Review.new(book_id: params[:review][:book_id].to_i, rating: params[:review][:rating].to_i, content: params[:review][:content], title: params[:review][:title])
    @review.user = current_user

    if @review.save
      redirect_to reviews_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @review.user = current_user

    if @review.destroy
      redirect_to reviews_url, notice: "Review was successfully destroyed."
    else
      redirect_to reviews_url, alert: "Failed to delete review."
    end
  end
end

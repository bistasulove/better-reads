class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  # GET /books
  def index
    @books = Book.all
    @book_scores = scores_for(BookVote, :book_id, @books)
    @my_book_votes = my_votes_for(BookVote, :book_id, @books)
  end

  # GET /books/1
  def show
    @reviews = @book.reviews
    @review_scores = scores_for(ReviewVote, :review_id, @reviews)
    @my_review_votes = my_votes_for(ReviewVote, :review_id, @reviews)
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @book.destroy
      redirect_to books_url, notice: "Book was successfully destroyed."
    else
      redirect_to books_url, alert: "Failed to delete book."
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Book.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def book_params
    params.require(:book).permit(:title, :author_id, :description)
  end

  # One query for every score on the page, instead of one per record.
  # Returns { record_id => score }; records with no votes are absent.
  def scores_for(vote_class, foreign_key, records)
    vote_class.where(foreign_key => records).group(foreign_key).sum(:value)
  end

  # One query for the current user's votes on everything on the page.
  # Returns { record_id => 1 or -1 }.
  def my_votes_for(vote_class, foreign_key, records)
    vote_class.where(user: current_user, foreign_key => records).pluck(foreign_key, :value).to_h
  end
end

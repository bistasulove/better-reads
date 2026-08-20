class CreateReviewVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :review_votes do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :review, null: false, foreign_key: true
      t.integer :value, null: false 
      t.timestamps
    end

    add_index :review_votes, [:user_id, :review_id], unique: true
    add_check_constraint :review_votes, "value IN (-1, 1)", name: "review_votes_value_check"
  end
end

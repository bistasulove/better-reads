class CreateBookVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :book_votes do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :book, null: false, foreign_key: true
      t.integer :value, null: false 
      t.timestamps
    end

    add_index :book_votes, [:user_id, :book_id], unique: true
    add_check_constraint :book_votes, "value IN (-1, 1)", name: "book_votes_value_check"
  end
end
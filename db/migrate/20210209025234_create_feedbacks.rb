class CreateFeedbacks < ActiveRecord::Migration[6.0]
  def change
    create_table :feedbacks do |t|
      t.integer :user_id
      t.integer :team_id
      t.integer :rating, null: false
      t.string :comments, limit: 255
      t.datetime :timestamp

      t.timestamps
    end
  end
end

class EditUsers < ActiveRecord::Migration[6.0]
  def change
      add_index :users, :user_id, unique: true
  end
end

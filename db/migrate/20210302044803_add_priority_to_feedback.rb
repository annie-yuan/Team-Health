class AddPriorityToFeedback < ActiveRecord::Migration[6.0]
  def change
    add_column :feedbacks, :priority, :integer, :default => 2, :null => false
  end
end

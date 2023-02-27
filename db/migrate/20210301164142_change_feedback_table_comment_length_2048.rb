class ChangeFeedbackTableCommentLength2048 < ActiveRecord::Migration[6.0]
  def change
    change_column :feedbacks, :comments, :string, limit: 2048
  end
end

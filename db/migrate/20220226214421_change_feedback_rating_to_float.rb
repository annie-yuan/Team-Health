class ChangeFeedbackRatingToFloat < ActiveRecord::Migration[6.1]
  def change
    change_column :feedbacks, :rating, :float
  end
end

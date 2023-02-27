class AddNotNullFeedbackTimestamp < ActiveRecord::Migration[6.0]
  def change
    change_column_null :feedbacks, :timestamp, false
  end
end

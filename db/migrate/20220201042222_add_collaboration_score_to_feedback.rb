class AddCollaborationScoreToFeedback < ActiveRecord::Migration[6.1]
  def change
    add_column :feedbacks, :collaboration_score, :integer, :inclusion => 1..5
    add_column :feedbacks, :communication_score, :integer, :inclusion => 1..5
    add_column :feedbacks, :time_management_score, :integer, :inclusion => 1..5
    add_column :feedbacks, :problem_solving_score, :integer, :inclusion => 1..5
    add_column :feedbacks, :knowledge_of_roles_score, :integer, :inclusion => 1..5
  end
end

class AddPriorityToReports < ActiveRecord::Migration[6.0]
  def change
    add_column :reports, :priority, :integer, :default => 2, :null => false
  end
end

class DeleteCascadeUsers < ActiveRecord::Migration[6.0]
  def change
     # add cascading delete to teams
     remove_foreign_key :teams, :users
     add_foreign_key :teams, :users, on_delete: :cascade
     
     # add cascading delete to reports
     remove_index :reports, :reporter_id
     remove_foreign_key :reports, :users, column: :reporter_id
     add_foreign_key :reports, :users, column: :reporter_id, on_delete: :cascade
     add_index :reports, :reporter_id
     remove_index :reports, :reportee_id
     remove_foreign_key :reports, :users, column: :reportee_id
     add_foreign_key :reports, :users, column: :reportee_id, on_delete: :cascade
     add_index :reports, :reportee_id
    
     # add cascading delete to feedbacks
     remove_foreign_key :feedbacks, :users
     add_foreign_key :feedbacks, :users, on_delete: :cascade
  end
end
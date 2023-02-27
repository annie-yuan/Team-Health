class CreateJoinTeamStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :join_team_statuses do |t|
      t.references :team
      t.references :user
      t.integer :status
      t.timestamps
    end
  end
end

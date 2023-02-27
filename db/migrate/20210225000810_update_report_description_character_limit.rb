class UpdateReportDescriptionCharacterLimit < ActiveRecord::Migration[6.0]
  def change
    change_column(:reports, :description, :string, limit: 2048)
  end
end

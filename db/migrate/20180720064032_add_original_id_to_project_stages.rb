class AddOriginalIdToProjectStages < ActiveRecord::Migration
  def change
    add_column :project_stages, :original_id, :integer
  end
end

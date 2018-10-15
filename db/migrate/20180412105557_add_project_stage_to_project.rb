class AddProjectStageToProject < ActiveRecord::Migration
  def change
    add_column :projects, :project_stage_id, :integer
    add_index :projects, :project_stage_id
  end
end

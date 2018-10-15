class AddOriginalIdToProjectJobTypes < ActiveRecord::Migration
  def up
    add_column :project_job_types, :original_id, :integer
    add_column :task_types, :original_id, :integer
    
  end
  def down
    remove_column :project_job_types, :original_id
    remove_column :task_types, :original_id
  end
end

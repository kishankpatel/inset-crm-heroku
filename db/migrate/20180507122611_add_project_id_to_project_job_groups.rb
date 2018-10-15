class AddProjectIdToProjectJobGroups < ActiveRecord::Migration
  def change
    add_column :project_job_groups, :project_id, :integer
    add_index :project_job_groups, :project_id
    execute "update project_job_groups inner join project_jobs on project_jobs.project_job_group_id = project_job_groups.id set project_job_groups.project_id = project_jobs.project_id "
  end
end

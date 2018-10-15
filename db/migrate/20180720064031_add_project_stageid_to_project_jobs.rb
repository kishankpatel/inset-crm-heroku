class AddProjectStageidToProjectJobs < ActiveRecord::Migration
  def change
    add_column :project_jobs, :project_stage_id, :integer
    execute <<-__EOI
      update project_jobs INNER JOIN  projects ON projects.id = project_jobs.project_id set project_jobs.project_stage_id=projects.project_stage_id   ;
    __EOI
  end
end

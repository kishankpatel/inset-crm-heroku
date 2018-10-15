class AddEstimationToProjectJobs < ActiveRecord::Migration
  def change
    add_column :project_jobs, :estimate_minutes, :integer
    execute <<-__EOI
      update project_jobs set estimate_minutes = estimate_hour * 60;
    __EOI
  end
end

class AddJobNoToProjectJob < ActiveRecord::Migration
  def change
    add_column :project_jobs, :job_no, :integer
  end
end

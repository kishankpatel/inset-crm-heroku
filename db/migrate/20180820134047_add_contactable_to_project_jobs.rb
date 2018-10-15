class AddContactableToProjectJobs < ActiveRecord::Migration
  def change
    add_column :project_jobs, :contactable_type, :string
    add_column :project_jobs, :contactable_id, :integer
  end
end

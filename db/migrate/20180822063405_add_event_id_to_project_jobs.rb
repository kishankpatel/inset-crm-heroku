class AddEventIdToProjectJobs < ActiveRecord::Migration
  def change
    add_column :project_jobs, :event_source, :string
    add_column :project_jobs, :event_id, :string
    add_column :tasks, :event_source, :string
    add_column :tasks, :event_id, :string
  end
end

class AddFieldsToProjectJob < ActiveRecord::Migration
  def change
    add_column :project_jobs, :is_completed, :boolean, :default => false
    add_column :project_jobs, :resolved_at, :datetime
    add_column :project_jobs, :closed_at, :datetime
  end
end

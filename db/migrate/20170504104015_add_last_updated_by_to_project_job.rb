class AddLastUpdatedByToProjectJob < ActiveRecord::Migration
  def change
    add_column :project_jobs, :last_updated_by, :integer
  end
end

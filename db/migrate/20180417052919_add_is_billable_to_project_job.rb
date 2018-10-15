class AddIsBillableToProjectJob < ActiveRecord::Migration
  def change
    add_column :project_jobs, :is_billable, :boolean
  end
end

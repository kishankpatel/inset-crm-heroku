class AddIsArchiveToProjectJob < ActiveRecord::Migration
  def change
    add_column :project_jobs, :is_archive, :boolean, :default => false
  end
end

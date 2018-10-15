class AddProgressToProjectJob < ActiveRecord::Migration
  def change
    add_column :project_jobs, :progress, :integer
  end
end

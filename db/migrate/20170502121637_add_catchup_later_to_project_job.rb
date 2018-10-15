class AddCatchupLaterToProjectJob < ActiveRecord::Migration
  def change
    add_column :project_jobs, :catchup_later, :boolean, :default => false
  end
end

class AddIsCompletedToProject < ActiveRecord::Migration
  def change
    add_column :projects, :is_completed, :boolean, :default => false
  end
end

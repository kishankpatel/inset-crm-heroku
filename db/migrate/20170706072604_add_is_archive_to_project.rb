class AddIsArchiveToProject < ActiveRecord::Migration
  def change
    add_column :projects, :is_archive, :boolean, :default => false
  end
end

class AddFieldsToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :is_archive, :boolean, default: false
    add_column :tasks, :archive_by, :integer
  end
end

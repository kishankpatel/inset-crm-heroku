class AddDetailsToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :details, :text
  end
end

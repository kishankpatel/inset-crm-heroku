class AddPrioriyStatusToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :priority, :string
    add_column :tasks, :status, :string
  end
end

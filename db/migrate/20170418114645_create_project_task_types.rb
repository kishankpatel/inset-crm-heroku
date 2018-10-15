class CreateProjectTaskTypes < ActiveRecord::Migration
  def change
    create_table :project_task_types do |t|
      t.string :name
      t.references :organization

      t.timestamps
    end
    add_index :project_task_types, :organization_id
  end
end

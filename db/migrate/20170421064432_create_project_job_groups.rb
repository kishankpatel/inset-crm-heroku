class CreateProjectJobGroups < ActiveRecord::Migration
  def change
    create_table :project_job_groups do |t|
      t.string :name
      t.references :organization

      t.timestamps
    end
    add_index :project_job_groups, :organization_id
  end
end

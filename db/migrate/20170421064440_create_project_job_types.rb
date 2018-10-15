class CreateProjectJobTypes < ActiveRecord::Migration
  def change
    create_table :project_job_types do |t|
      t.string :name
      t.references :organization

      t.timestamps
    end
    add_index :project_job_types, :organization_id
  end
end

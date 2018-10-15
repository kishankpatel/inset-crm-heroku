class CreateResourceDistributions < ActiveRecord::Migration
  def change
    create_table :resource_distributions do |t|
      t.references :project
      t.references :project_job
      t.references :user
      t.date :allotted_date
      t.integer :allotted_time

      t.timestamps
    end
    add_index :resource_distributions, :project_id
    add_index :resource_distributions, :project_job_id
    add_index :resource_distributions, :user_id
  end
end

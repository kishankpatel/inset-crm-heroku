class CreateProjectJobs < ActiveRecord::Migration
  def change
    create_table :project_jobs do |t|
      t.string :name
      t.integer :assigned_to
      t.integer :created_by
      t.string :priority
      t.text :description
      t.datetime :start_date
      t.datetime :due_date
      t.integer :estimate_hour
      t.boolean :is_repeat, :default => false
      t.string :notify_email_ids
      t.string :status
      t.references :project_job_type
      t.references :project_job_group
      t.references :individual_contact
      t.references :organization
      t.references :project

      t.timestamps
    end
    add_index :project_jobs, :project_job_type_id
    add_index :project_jobs, :project_job_group_id
    add_index :project_jobs, :individual_contact_id
  end
end

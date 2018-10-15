class CreateTempProjects < ActiveRecord::Migration
  def change
    create_table :temp_projects do |t|
      t.references :organization
      t.references :user
      t.string :name
      t.string :short_name
      t.date :start_date
      t.date :end_date
      t.string :opportunity
      t.string :contact_email
      t.integer :estimate_hour
      t.string :default_job_type
      t.text :description
      t.string :team_emails
      t.boolean :is_completed
      t.string :stage

      t.timestamps
    end
    add_index :temp_projects, :organization_id
    add_index :temp_projects, :user_id
  end
end

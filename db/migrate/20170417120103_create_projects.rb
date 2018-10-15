class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :short_name
      t.datetime :start_date
      t.datetime :end_date
      t.time :estimate_hour
      t.integer :created_by
      t.string :status
      t.text :description
      t.references :deal
      t.references :organization
      t.references :individual_contact
      t.references :project_task_type

      t.timestamps
    end
    add_index :projects, :deal_id
  end
end

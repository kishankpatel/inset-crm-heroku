class CreateProjectJobRepeats < ActiveRecord::Migration
  def change
    create_table :project_job_repeats do |t|
      t.integer :created_by
      t.string :repeat_type
      t.datetime :repeat_start
      t.datetime :repeat_end_on
      t.integer :repeat_occurrences
      t.references :organization
      t.references :project_job

      t.timestamps
    end
    add_index :project_job_repeats, :organization_id
    add_index :project_job_repeats, :project_job_id
  end
end

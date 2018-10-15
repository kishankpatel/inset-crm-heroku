class CreateJobTimeLogs < ActiveRecord::Migration
  def change
    create_table :job_time_logs do |t|
      t.references :project_job
      t.references :user
      t.datetime :log_start_time
      t.datetime :log_end_time
      t.integer :break_time
      t.integer :spent_hours
      t.text :note
      t.boolean :is_billable

      t.timestamps
    end
    add_index :job_time_logs, :project_job_id
    add_index :job_time_logs, :user_id
  end
end

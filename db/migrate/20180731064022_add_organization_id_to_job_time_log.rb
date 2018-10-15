class AddOrganizationIdToJobTimeLog < ActiveRecord::Migration
  def change
    add_column :job_time_logs, :organization_id, :integer
    add_index :job_time_logs, :organization_id
  end
end

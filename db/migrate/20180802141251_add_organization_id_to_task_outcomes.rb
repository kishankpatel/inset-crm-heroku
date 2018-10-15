class AddOrganizationIdToTaskOutcomes < ActiveRecord::Migration
  def change
    add_column :task_outcomes, :organization_id, :integer
  end
end

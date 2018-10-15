class AddNewColumnsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :is_trial_expired, :boolean, :default => false
    add_column :organizations, :extend_trial_days, :integer, :default => 0
  end
end

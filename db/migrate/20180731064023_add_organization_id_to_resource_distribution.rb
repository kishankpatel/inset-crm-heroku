class AddOrganizationIdToResourceDistribution < ActiveRecord::Migration
  def change
    add_column :resource_distributions, :organization_id, :integer
    add_index :resource_distributions, :organization_id
  end
end

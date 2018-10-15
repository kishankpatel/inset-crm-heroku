class AddOrganizationToResourceSetting < ActiveRecord::Migration
  def change
    add_column :resource_settings, :organization_id, :integer
    add_index :resource_settings, :organization_id
  end
end

class AddColumnsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :current_sub_id, :integer
    add_column :organizations, :current_user_limit, :integer
    add_column :organizations, :current_storage_limit, :integer
    add_column :organizations, :is_sub_active, :boolean, :default => true
    add_column :organizations, :trial_expires_on, :datetime


    Organization.update_all trial_expires_on: (Time.now+30.days)
    # User.where(["admin_type not in (?)", [0,1]]).update_all is_active: false

  end
end

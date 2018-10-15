class AddLimitsToOrganization < ActiveRecord::Migration
  def change
    # add_column :organizations, :users_limit, :integer, :default => 5
    add_column :organizations, :is_free_plan, :boolean, :default => false
    add_column :organizations, :leads_limit, :integer, :default => 25
    add_column :organizations, :contacts_limit, :integer, :default => 35
    add_column :organizations, :tasks_limit, :integer, :default => 50
    add_column :organizations, :projects_limit, :integer, :default => 2
    add_column :organizations, :proj_tasks_limit, :integer, :default => 20
    add_column :organizations, :allow_gmail, :boolean, :default => false
    add_column :organizations, :allow_invoice, :boolean, :default => false
    add_column :organizations, :allow_email_tracking, :boolean, :default => false
    add_column :organizations, :allow_web_to_lead, :boolean, :default => false
    add_column :organizations, :change_permissions, :boolean, :default => false
  end
end

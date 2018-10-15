class AddIsAccessibleToTable < ActiveRecord::Migration
  def change
    add_column :deals, :is_accessible, :boolean, :default => true
    add_column :tasks, :is_accessible, :boolean, :default => true
    add_column :projects, :is_accessible, :boolean, :default => true
    add_column :project_jobs, :is_accessible, :boolean, :default => true
    add_column :individual_contacts, :is_accessible, :boolean, :default => true
    add_column :company_contacts, :is_accessible, :boolean, :default => true
  end
end

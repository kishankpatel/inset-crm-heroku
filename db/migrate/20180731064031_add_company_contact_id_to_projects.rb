class AddCompanyContactIdToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :company_contact_id, :integer
    add_column :projects, :linked_with, :string

  end
end

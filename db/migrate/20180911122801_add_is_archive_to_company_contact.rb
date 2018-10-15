class AddIsArchiveToCompanyContact < ActiveRecord::Migration
  def change
    add_column :company_contacts, :is_archive, :boolean, :default => false
  end
end

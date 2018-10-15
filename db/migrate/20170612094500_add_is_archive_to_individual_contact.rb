class AddIsArchiveToIndividualContact < ActiveRecord::Migration
  def change
    add_column :individual_contacts, :is_archive, :boolean, :default => false
  end
end

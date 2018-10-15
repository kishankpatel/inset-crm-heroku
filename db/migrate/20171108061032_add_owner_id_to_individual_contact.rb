class AddOwnerIdToIndividualContact < ActiveRecord::Migration
  def change
    add_column :individual_contacts, :owner_id, :integer
  end
end

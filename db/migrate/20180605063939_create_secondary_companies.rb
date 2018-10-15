class CreateSecondaryCompanies < ActiveRecord::Migration
  def change
    create_table :secondary_companies do |t|
      t.references :organization
      t.references :individual_contact
      t.references :company_contact

      t.timestamps
    end
    add_index :secondary_companies, :organization_id
    add_index :secondary_companies, :individual_contact_id
    add_index :secondary_companies, :company_contact_id
  end
end

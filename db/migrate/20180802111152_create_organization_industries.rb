class CreateOrganizationIndustries < ActiveRecord::Migration
  def change
    create_table :organization_industries do |t|
      t.references :organization
      t.references :company_industry

      t.timestamps
    end
    add_index :organization_industries, :organization_id
    add_index :organization_industries, :company_industry_id
  end
end

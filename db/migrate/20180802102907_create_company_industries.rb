class CreateCompanyIndustries < ActiveRecord::Migration
  def change
    create_table :company_industries do |t|
      t.string :name
      t.string :industry_code

      t.timestamps
    end
  end
end

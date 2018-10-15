class AddDefaultCurrencyToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :default_currency, :string, :default => "US$"
  end
  
end

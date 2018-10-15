class AddCurrencyTypeToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :currency_type, :string, default:"US$"
  end
end

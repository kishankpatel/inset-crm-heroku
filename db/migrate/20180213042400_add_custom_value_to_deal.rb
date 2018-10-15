class AddCustomValueToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :custom_value, :string
  end
end

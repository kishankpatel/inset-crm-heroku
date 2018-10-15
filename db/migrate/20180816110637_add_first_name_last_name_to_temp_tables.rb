class AddFirstNameLastNameToTempTables < ActiveRecord::Migration
  def change
    add_column :temp_tables, :first_name, :string
    add_column :temp_tables, :last_name, :string
  end
end

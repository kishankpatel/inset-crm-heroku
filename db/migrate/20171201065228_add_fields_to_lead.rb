class AddFieldsToLead < ActiveRecord::Migration
  def change
    add_column :deals, :closed_date, :datetime
    add_column :deals, :expected_close_date, :datetime
  end
end

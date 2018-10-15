class CreateUserHourlyBillables < ActiveRecord::Migration
  def change
    create_table :user_hourly_billables do |t|
      t.integer :amount
      t.references :organization

      t.timestamps
    end
    add_index :user_hourly_billables, :organization_id
    add_column :users, :user_hourly_billable_id, :integer
  end
end

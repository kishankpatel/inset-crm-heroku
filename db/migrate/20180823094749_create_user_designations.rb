class CreateUserDesignations < ActiveRecord::Migration
  def change
    create_table :user_designations do |t|
      t.string :name
      t.references :organization

      t.timestamps
    end
    add_index :user_designations, :organization_id
    add_column :users, :user_designation_id, :integer
  end
end

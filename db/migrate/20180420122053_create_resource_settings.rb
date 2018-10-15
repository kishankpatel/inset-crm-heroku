class CreateResourceSettings < ActiveRecord::Migration
  def change
    create_table :resource_settings do |t|
      t.integer :hours_of_work
      t.string :week_off_days

      t.timestamps
    end
  end
end

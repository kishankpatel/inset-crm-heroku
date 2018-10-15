class CreateLostReasons < ActiveRecord::Migration  
  def up
    create_table :lost_reasons do |t|
      t.text :reason
      t.integer :organization_id
      t.timestamps
    end
  end
  def down
    drop_table :lost_reasons
  end
end

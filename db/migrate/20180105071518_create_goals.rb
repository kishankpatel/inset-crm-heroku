class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.integer :organization_id
      t.integer :user_id
      t.string :goal_type
      t.integer :deal_stage_id
      t.string :period
      t.integer :quantity_deal
      t.string :value
      t.string :currency
      t.timestamps
    end
  end
end

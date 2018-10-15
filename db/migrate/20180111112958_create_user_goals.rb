class CreateUserGoals < ActiveRecord::Migration
  def change
    create_table :user_goals do |t|
      t.integer :goal_id
      t.integer :user_id
      t.integer :deal_id
      t.string :amount
      t.timestamps
    end
  end
end

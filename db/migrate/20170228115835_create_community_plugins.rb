class CreateCommunityPlugins < ActiveRecord::Migration
  def change
    create_table :community_plugins do |t|
      t.string :name
      t.integer :price
      t.text :description
      t.string :unique_id
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end

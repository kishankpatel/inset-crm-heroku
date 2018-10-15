class CreateUserPlugins < ActiveRecord::Migration
  def change
    create_table :user_plugins do |t|
      t.references :user
      t.references :plugin

      t.timestamps
    end
    add_index :user_plugins, :user_id
    add_index :user_plugins, :plugin_id
  end
end

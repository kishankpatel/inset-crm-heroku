class AddIsPluginToCommunityPlugin < ActiveRecord::Migration
  def change
    add_column :community_plugins, :is_plugin, :boolean, :default => true
  end
end

class UpdateTypeInCommunityPlugin < ActiveRecord::Migration
  def change
  	change_column :community_plugins, :unique_id, :text
  end
end

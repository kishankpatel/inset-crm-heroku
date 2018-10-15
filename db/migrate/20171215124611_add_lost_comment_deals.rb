class AddLostCommentDeals < ActiveRecord::Migration
  def up
  	add_column :deals, :lost_comment, :text
  end

  def down
  	add_column :deals, :lost_comment
  end
end

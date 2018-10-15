class AddDownloadCountToPluginTransaction < ActiveRecord::Migration
  def change
    add_column :plugin_transactions, :download_count, :integer, :default => 0
  end
end

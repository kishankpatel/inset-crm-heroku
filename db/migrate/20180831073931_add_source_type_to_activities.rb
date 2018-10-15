class AddSourceTypeToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :source_type, :string
  end
end

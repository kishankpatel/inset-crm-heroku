class AddDeactivatedByToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :deactivated_by, :integer
  end
end

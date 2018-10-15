class AddLimitToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :users_limit, :integer, :default => 10
  end
end

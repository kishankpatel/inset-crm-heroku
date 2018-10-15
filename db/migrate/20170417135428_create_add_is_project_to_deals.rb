class CreateAddIsProjectToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :is_project, :boolean, :default => false
  	add_column :deals, :project_id, :integer
  end
end

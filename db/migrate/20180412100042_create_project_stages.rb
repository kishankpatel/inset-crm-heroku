class CreateProjectStages < ActiveRecord::Migration
  def change
    create_table :project_stages do |t|
      t.references :organization
      t.string :name
      t.boolean :is_active
      t.integer :position

      t.timestamps
    end
    add_index :project_stages, :organization_id
  end
end

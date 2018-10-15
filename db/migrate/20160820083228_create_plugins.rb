class CreatePlugins < ActiveRecord::Migration
  def change
    create_table :plugins do |t|
      t.string :title
      t.text :description
      t.boolean :is_active

      t.timestamps
    end
  end
end

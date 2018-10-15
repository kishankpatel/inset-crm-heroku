class CreateProjectUsers < ActiveRecord::Migration
  def change
    create_table :project_users do |t|
      t.references :project
      t.references :user

      t.timestamps
    end
    add_index :project_users, :project_id
    add_index :project_users, :user_id
  end
end

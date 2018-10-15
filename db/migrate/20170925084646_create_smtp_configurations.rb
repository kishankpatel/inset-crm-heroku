class CreateSmtpConfigurations < ActiveRecord::Migration
  def change
    create_table :smtp_configurations do |t|
      t.string :smtp_host
      t.string :port
      t.string :email
      t.string :user_name
      t.string :password
      t.integer :organization_id
      t.integer :user_id

      t.timestamps
    end
  end
end

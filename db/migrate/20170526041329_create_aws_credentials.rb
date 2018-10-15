class CreateAwsCredentials < ActiveRecord::Migration
  def change
    create_table :aws_credentials do |t|
      t.string :access_key
      t.string :secret_key

      t.timestamps
    end
  end
end

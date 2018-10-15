class CreateSpamEmails < ActiveRecord::Migration
  def change
    create_table :spam_emails do |t|
      t.string :email
      t.string :nickname
      t.string :organization_name
      t.string :region_name
      t.string :city
      t.string :country_name
      t.string :latitude
      t.string :longitude
      t.string :ip
      t.string :time_zone
      t.timestamps
    end
  end
end

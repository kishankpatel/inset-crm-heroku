class CreateWebForms < ActiveRecord::Migration
  def change
    create_table :web_forms do |t|
      t.integer :organization_id
      t.string :form_unique_id
      t.string :form_name
      t.integer :user_responsible
      t.integer :source_id
      t.boolean :is_display_thank_you_page
      t.string :external_link
      t.boolean :send_email_notification
      t.text :field_names
      t.text :form_html_code
      t.integer :created_by
      t.boolean :is_active, default: true
      t.string :email_to

      t.timestamps
    end
  end
end

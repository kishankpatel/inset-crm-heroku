class AddFieldsToBounceEmail < ActiveRecord::Migration
  def change
    add_column :bounce_emails, :subject, :string
    add_column :bounce_emails, :json_response, :text
  end
end

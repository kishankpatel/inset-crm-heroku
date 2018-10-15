class AddMailDomainToMailLetter < ActiveRecord::Migration
  def change
    add_column :mail_letters, :mail_domain, :string
    add_column :mail_letters, :mail_id, :string
    add_column :mail_letters, :mail_from, :string
  end
end

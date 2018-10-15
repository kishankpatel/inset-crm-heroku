class AddWebFormIdToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :web_form_id, :integer
  end
end

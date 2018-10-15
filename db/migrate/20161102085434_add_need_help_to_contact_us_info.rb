class AddNeedHelpToContactUsInfo < ActiveRecord::Migration
  def change
    add_column :contact_us_infos, :need_help, :string
  end
end

class CreateBugReports < ActiveRecord::Migration
  def change
    create_table :bug_reports do |t|
      t.string :platform
      t.string :name
      t.string :email
      t.string :bug_type
      t.text :comments
      t.boolean :is_resolved, :default => false

      t.timestamps
    end
  end
end

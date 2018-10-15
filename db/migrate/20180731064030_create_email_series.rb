class CreateEmailSeries < ActiveRecord::Migration
  def change
    
    create_table "email_series" do |t|
    t.integer  "user_id"
    t.integer  "org_id"
    t.string   "org_name"
    t.string   "email"
    t.string   "name"
    t.datetime "signup_date"
    t.string   "email_sent_for"
    t.date     "email_sent_at"
    t.boolean  "is_next_tosend",  :default => true
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "is_unsubscribe",  :default => false
    t.boolean  "is_email_opened", :default => false
    t.integer  "opened_count",    :default => 0
    t.datetime "last_opened_at"
  end
end
  
end

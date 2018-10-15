# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20180911122801) do

  create_table "Tempsplitvalues", :force => true do |t|
    t.string "item"
  end

  create_table "activities", :force => true do |t|
    t.integer  "organization_id"
    t.string   "activity_type"
    t.integer  "activity_id"
    t.integer  "activity_user_id"
    t.string   "activity_status"
    t.string   "activity_desc"
    t.datetime "activity_date"
    t.boolean  "is_public",        :default => true,  :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "source_id"
    t.boolean  "is_available",     :default => false
    t.integer  "activity_by"
    t.string   "source_type"
  end

  add_index "activities", ["activity_date"], :name => "index_activities_on_activity_date"
  add_index "activities", ["activity_user_id"], :name => "index_activities_on_activity_user_id"
  add_index "activities", ["organization_id"], :name => "index_activities_on_organization_id"
  add_index "activities", ["source_id"], :name => "index_activities_on_source_id"

  create_table "activities_contacts", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "activity_id"
    t.string   "contactable_type"
    t.integer  "contactable_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "addresses", :force => true do |t|
    t.integer  "organization_id"
    t.string   "address_type"
    t.text     "address"
    t.integer  "country_id"
    t.string   "state"
    t.string   "city"
    t.string   "zipcode"
    t.string   "addressable_type"
    t.integer  "addressable_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "addresses", ["country_id"], :name => "index_addresses_on_country_id"
  add_index "addresses", ["organization_id"], :name => "index_addresses_on_organization_id"

  create_table "ahoy_messages", :force => true do |t|
    t.string   "token"
    t.text     "to"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "mailer"
    t.text     "subject"
    t.text     "content"
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
  end

  add_index "ahoy_messages", ["token"], :name => "index_ahoy_messages_on_token"
  add_index "ahoy_messages", ["user_id", "user_type"], :name => "index_ahoy_messages_on_user_id_and_user_type"

  create_table "api_integrations", :force => true do |t|
    t.integer  "organization_id"
    t.string   "url"
    t.string   "api_name"
    t.string   "account_id"
    t.string   "auth_token"
    t.string   "oauth_access_token"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "attention_deals", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.text     "deal_ids"
    t.integer  "deal_count"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "aws_credentials", :force => true do |t|
    t.string   "access_key"
    t.string   "secret_key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "beta_accounts", :force => true do |t|
    t.string   "email"
    t.text     "invitation_token"
    t.integer  "invited_by"
    t.boolean  "is_verified",          :default => false
    t.boolean  "is_approved",          :default => false
    t.boolean  "is_registered",        :default => false
    t.boolean  "is_siteadmin_invited", :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "bigbluebutton_meetings", :force => true do |t|
    t.integer  "server_id"
    t.integer  "room_id"
    t.string   "meetingid"
    t.string   "name"
    t.datetime "start_time"
    t.boolean  "running",      :default => false
    t.boolean  "record",       :default => false
    t.integer  "creator_id"
    t.string   "creator_name"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "bigbluebutton_meetings", ["meetingid", "start_time"], :name => "index_bigbluebutton_meetings_on_meetingid_and_start_time", :unique => true

  create_table "bigbluebutton_metadata", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bigbluebutton_playback_formats", :force => true do |t|
    t.integer  "recording_id"
    t.string   "format_type"
    t.string   "url"
    t.integer  "length"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "bigbluebutton_recordings", :force => true do |t|
    t.integer  "server_id"
    t.integer  "room_id"
    t.integer  "meeting_id"
    t.string   "recordid"
    t.string   "meetingid"
    t.string   "name"
    t.boolean  "published",   :default => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "available",   :default => true
    t.string   "description"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "bigbluebutton_recordings", ["recordid"], :name => "index_bigbluebutton_recordings_on_recordid", :unique => true
  add_index "bigbluebutton_recordings", ["room_id"], :name => "index_bigbluebutton_recordings_on_room_id"

  create_table "bigbluebutton_room_options", :force => true do |t|
    t.integer  "room_id"
    t.string   "default_layout"
    t.boolean  "presenter_share_only"
    t.boolean  "auto_start_video"
    t.boolean  "auto_start_audio"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "bigbluebutton_room_options", ["room_id"], :name => "index_bigbluebutton_room_options_on_room_id"

  create_table "bigbluebutton_rooms", :force => true do |t|
    t.integer  "server_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "meetingid"
    t.string   "name"
    t.string   "attendee_password"
    t.string   "moderator_password"
    t.string   "welcome_msg"
    t.string   "logout_url"
    t.string   "voice_bridge"
    t.string   "dial_number"
    t.integer  "max_participants"
    t.boolean  "private",            :default => false
    t.boolean  "external",           :default => false
    t.string   "param"
    t.boolean  "record",             :default => false
    t.integer  "duration",           :default => 0
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "bigbluebutton_rooms", ["meetingid"], :name => "index_bigbluebutton_rooms_on_meetingid", :unique => true
  add_index "bigbluebutton_rooms", ["server_id"], :name => "index_bigbluebutton_rooms_on_server_id"
  add_index "bigbluebutton_rooms", ["voice_bridge"], :name => "index_bigbluebutton_rooms_on_voice_bridge", :unique => true

  create_table "bigbluebutton_servers", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "salt"
    t.string   "version"
    t.string   "param"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bounce_emails", :force => true do |t|
    t.integer  "organization_id"
    t.string   "sender_email"
    t.string   "recipient_email"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "subject"
    t.text     "json_response"
  end

  create_table "bug_reports", :force => true do |t|
    t.string   "platform"
    t.string   "name"
    t.string   "email"
    t.string   "bug_type"
    t.text     "comments"
    t.boolean  "is_resolved", :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "status"
    t.integer  "assigned_to"
    t.string   "priority"
    t.string   "notify_email_ids"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "community_plugins", :force => true do |t|
    t.string   "name"
    t.integer  "price"
    t.text     "description"
    t.text     "unique_id"
    t.boolean  "is_active",   :default => true
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_plugin",   :default => true
  end

  create_table "company_contacts", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "company_strength_id"
    t.string   "email"
    t.string   "messanger_type"
    t.string   "messanger_id"
    t.string   "website"
    t.string   "linkedin_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.integer  "created_by"
    t.boolean  "is_public",                :default => true,  :null => false
    t.boolean  "is_active",                :default => true,  :null => false
    t.integer  "contact_ref_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "time_zone"
    t.integer  "country_id"
    t.boolean  "is_accessible",            :default => true
    t.integer  "total_opportunities",      :default => 0
    t.integer  "total_open_opportunities", :default => 0
    t.boolean  "is_archive",               :default => false
  end

  create_table "company_industries", :force => true do |t|
    t.string   "name"
    t.string   "industry_code"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "company_strengths", :force => true do |t|
    t.string   "range"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contact_opportunities", :force => true do |t|
    t.string   "opportunity"
    t.integer  "individual_contact_id"
    t.integer  "deal_id"
    t.boolean  "is_converted",          :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "contact_us", :force => true do |t|
    t.string   "email"
    t.boolean  "is_remote",  :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "contact_us_infos", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.string   "phone"
    t.integer  "contact_us_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "need_help"
  end

  add_index "contact_us_infos", ["contact_us_id"], :name => "index_contact_us_infos_on_contact_us_id"

  create_table "contacts", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "company_strength_id"
    t.string   "contact_type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "website"
    t.string   "messanger_type"
    t.string   "messanger_id"
    t.string   "linkedin_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.boolean  "is_public"
    t.integer  "created_by"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "is_active",           :default => true
  end

  add_index "contacts", ["company_strength_id"], :name => "index_contacts_on_company_strength_id"
  add_index "contacts", ["organization_id"], :name => "index_contacts_on_organization_id"

  create_table "countries", :force => true do |t|
    t.string  "ccode"
    t.string  "name"
    t.string  "isd_code"
    t.string  "flag"
    t.boolean "is_priority", :default => false
  end

  create_table "daily_updates", :force => true do |t|
    t.integer  "deal_id"
    t.string   "user_ids"
    t.time     "alert_time"
    t.string   "time_zone"
    t.string   "frequency"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "daily_updates", ["deal_id"], :name => "index_daily_updates_on_deal_id"

  create_table "deal_attachments", :force => true do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "deal_conversation_id",    :null => false
    t.integer  "organization_id",         :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "deal_conversations", :force => true do |t|
    t.integer  "user_id",         :null => false
    t.integer  "deal_id",         :null => false
    t.integer  "organization_id", :null => false
    t.text     "message"
    t.string   "subject"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "deal_industries", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.integer  "industry_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_industries", ["deal_id"], :name => "index_deal_industries_on_deal_id"
  add_index "deal_industries", ["industry_id"], :name => "index_deal_industries_on_industry_id"
  add_index "deal_industries", ["organization_id"], :name => "index_deal_industries_on_organization_id"

  create_table "deal_labels", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.integer  "user_label_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_labels", ["deal_id"], :name => "index_deal_labels_on_deal_id"
  add_index "deal_labels", ["organization_id"], :name => "index_deal_labels_on_organization_id"
  add_index "deal_labels", ["user_label_id"], :name => "index_deal_labels_on_user_label_id"

  create_table "deal_moves", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.integer  "deal_status_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_moves", ["deal_id"], :name => "index_deal_moves_on_deal_id"
  add_index "deal_moves", ["deal_status_id"], :name => "index_deal_moves_on_deal_status_id"
  add_index "deal_moves", ["organization_id"], :name => "index_deal_moves_on_organization_id"
  add_index "deal_moves", ["user_id"], :name => "index_deal_moves_on_user_id"

  create_table "deal_settings", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "tabs"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_settings", ["organization_id"], :name => "index_deal_settings_on_organization_id"
  add_index "deal_settings", ["user_id"], :name => "index_deal_settings_on_user_id"

  create_table "deal_sources", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.integer  "source_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "deal_sources", ["deal_id"], :name => "index_deal_sources_on_deal_id"
  add_index "deal_sources", ["organization_id"], :name => "index_deal_sources_on_organization_id"
  add_index "deal_sources", ["source_id"], :name => "index_deal_sources_on_source_id"

  create_table "deal_statuses", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "original_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "is_active",       :default => true,  :null => false
    t.boolean  "is_visible",      :default => true
    t.string   "color"
    t.boolean  "is_funnel_view",  :default => true
    t.boolean  "is_kanban",       :default => false
  end

  add_index "deal_statuses", ["organization_id"], :name => "index_deal_statuses_on_organization_id"

  create_table "deal_transactions", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.integer  "deal_status_id"
    t.integer  "user_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "is_activity_display", :default => true
    t.integer  "assigned_to"
  end

  create_table "deals", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.integer  "priority_type_id"
    t.integer  "assigned_to"
    t.integer  "contact_id"
    t.string   "tags"
    t.float    "amount"
    t.integer  "probability"
    t.integer  "attempts"
    t.boolean  "is_public",             :default => true
    t.integer  "initiated_by"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "deal_status_id"
    t.boolean  "is_active"
    t.boolean  "is_current"
    t.integer  "country_id"
    t.boolean  "is_csv",                :default => false
    t.boolean  "is_mail_sent",          :default => true
    t.integer  "closed_by"
    t.datetime "last_activity_date"
    t.text     "comments"
    t.boolean  "is_remote",             :default => false
    t.string   "app_type"
    t.integer  "latest_task_type_id"
    t.text     "contact_info"
    t.datetime "stage_move_date"
    t.string   "duration"
    t.string   "billing_type"
    t.boolean  "is_opportunity",        :default => false,      :null => false
    t.string   "payment_status",        :default => "Not done"
    t.string   "referrer"
    t.text     "hot_lead_token"
    t.datetime "token_expiry_time"
    t.integer  "next_priority_id"
    t.integer  "assignee_id"
    t.text     "visited"
    t.text     "location_by_api"
    t.integer  "individual_contact_id"
    t.integer  "user_label_id",         :default => 1
    t.integer  "web_form_id"
    t.boolean  "is_project",            :default => false
    t.integer  "project_id"
    t.integer  "deactivated_by"
    t.boolean  "is_accessible",         :default => true
    t.string   "currency_type",         :default => "US$"
    t.boolean  "is_won"
    t.text     "lost_reason"
    t.datetime "closed_date"
    t.datetime "expected_close_date"
    t.text     "lost_comment"
    t.float    "ref_billing_amount"
    t.string   "custom_value"
  end

  add_index "deals", ["organization_id"], :name => "index_deals_on_organization_id"
  add_index "deals", ["priority_type_id"], :name => "index_deals_on_priority_type_id"

  create_table "deals_contacts", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "deal_id"
    t.string   "contactable_type"
    t.integer  "contactable_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "download_users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "email_accounts", :force => true do |t|
    t.string   "provider"
    t.string   "email"
    t.string   "access_token"
    t.string   "refresh_token"
    t.boolean  "expires",         :default => true
    t.integer  "expires_in",      :default => 3600
    t.integer  "expires_at"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "email_notes", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "mail_letter_id"
    t.integer  "user_id"
    t.text     "notes"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "email_notifications", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "due_task"
    t.boolean  "task_assign"
    t.boolean  "deal_assign"
    t.boolean  "donot_send"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "email_series", :force => true do |t|
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

  create_table "feed_keywords", :force => true do |t|
    t.integer  "organization_id"
    t.string   "feed_tags"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "feed_keywords", ["organization_id"], :name => "index_feed_keywords_on_organization_id"

  create_table "goals", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "goal_type"
    t.integer  "deal_stage_id"
    t.string   "period"
    t.integer  "quantity_deal"
    t.string   "value"
    t.string   "currency"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "images", :force => true do |t|
    t.integer  "organization_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "imagable_type"
    t.integer  "imagable_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "images", ["organization_id"], :name => "index_images_on_organization_id"

  create_table "in_app_notifications", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "activity_type"
    t.string   "notificationable_type"
    t.integer  "notificationable_id"
    t.string   "message"
    t.boolean  "is_read",               :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "in_app_notifications", ["organization_id"], :name => "index_in_app_notifications_on_organization_id"
  add_index "in_app_notifications", ["user_id"], :name => "index_in_app_notifications_on_user_id"

  create_table "individual_contacts", :force => true do |t|
    t.integer  "organization_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "position"
    t.string   "messanger_type"
    t.string   "messanger_id"
    t.string   "linkedin_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.integer  "company_contact_id"
    t.integer  "created_by"
    t.boolean  "is_public",           :default => true,  :null => false
    t.boolean  "is_active",           :default => true,  :null => false
    t.integer  "contact_ref_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "time_zone"
    t.boolean  "is_customer",         :default => false, :null => false
    t.boolean  "subscribe_blog_mail", :default => true,  :null => false
    t.datetime "subscribe_blog_date"
    t.string   "website"
    t.string   "city"
    t.string   "state"
    t.integer  "country_id"
    t.string   "company_name"
    t.string   "work_phone"
    t.text     "description"
    t.boolean  "is_csv",              :default => false
    t.boolean  "is_archive",          :default => false
    t.boolean  "is_accessible",       :default => true
    t.integer  "owner_id"
  end

  create_table "industries", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "industries", ["organization_id"], :name => "index_industries_on_organization_id"

  create_table "invoice_items", :force => true do |t|
    t.text     "description"
    t.string   "amount"
    t.integer  "invoice_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "qty"
    t.float    "rate"
    t.integer  "job_time_log_id"
  end

  add_index "invoice_items", ["job_time_log_id"], :name => "index_invoice_items_on_job_time_log_id"

  create_table "invoices", :force => true do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.string   "contact_type"
    t.string   "currency"
    t.string   "invoice_no"
    t.date     "due_date"
    t.string   "cc_mail_id"
    t.string   "status"
    t.text     "notes"
    t.text     "terms_and_condition"
    t.date     "transaction_date"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "organization_id"
    t.string   "logo_url"
    t.integer  "deal_id"
    t.string   "company_name"
    t.text     "company_address"
    t.float    "tax"
    t.boolean  "is_sent",             :default => true
    t.string   "total_amount",        :default => "0"
    t.float    "discount"
    t.string   "po_number"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "billable_hours"
    t.integer  "project_id"
    t.string   "invoice_type",        :default => "invoice"
    t.boolean  "is_active",           :default => true
  end

  add_index "invoices", ["project_id"], :name => "index_invoices_on_project_id"

  create_table "job_time_logs", :force => true do |t|
    t.integer  "project_job_id"
    t.integer  "user_id"
    t.datetime "log_start_time"
    t.datetime "log_end_time"
    t.integer  "break_time"
    t.integer  "spent_hours"
    t.text     "note"
    t.boolean  "is_billable"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
  end

  add_index "job_time_logs", ["organization_id"], :name => "index_job_time_logs_on_organization_id"
  add_index "job_time_logs", ["project_job_id"], :name => "index_job_time_logs_on_project_job_id"
  add_index "job_time_logs", ["user_id"], :name => "index_job_time_logs_on_user_id"

  create_table "lost_reasons", :force => true do |t|
    t.text     "reason"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "mail_letters", :force => true do |t|
    t.integer  "organization_id"
    t.string   "mailable_type"
    t.integer  "mailable_id"
    t.string   "mailto"
    t.string   "subject"
    t.text     "description"
    t.integer  "mail_by"
    t.string   "mail_cc"
    t.string   "mail_bcc"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "contact_info"
    t.string   "mail_domain"
    t.string   "mail_id"
    t.string   "mail_from"
  end

  add_index "mail_letters", ["organization_id"], :name => "index_mail_letters_on_organization_id"

  create_table "mailbox_credentials", :force => true do |t|
    t.string   "client_id"
    t.string   "client_secret"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "note_attachments", :force => true do |t|
    t.integer  "note_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "organization_id"
    t.boolean  "is_archive",              :default => false
  end

  add_index "note_attachments", ["note_id"], :name => "index_note_attachments_on_note_id"

  create_table "note_types", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "note_types", ["organization_id"], :name => "index_note_types_on_organization_id"

  create_table "notes", :force => true do |t|
    t.integer  "organization_id"
    t.text     "notes"
    t.string   "file_description"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string   "notable_type"
    t.integer  "notable_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "created_by"
    t.boolean  "is_public",               :default => false
    t.string   "title"
    t.integer  "note_type_id"
  end

  add_index "notes", ["organization_id"], :name => "index_notes_on_organization_id"

  create_table "office_mails", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "office_mail"
    t.text     "token_hash"
    t.text     "token"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "office_mails", ["organization_id"], :name => "index_office_mails_on_organization_id"
  add_index "office_mails", ["user_id"], :name => "index_office_mails_on_user_id"

  create_table "opportunities", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "year"
    t.integer  "quarter"
    t.integer  "total_deals"
    t.integer  "won_deals"
    t.float    "win"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "organization_industries", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "company_industry_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "organization_industries", ["company_industry_id"], :name => "index_organization_industries_on_company_industry_id"
  add_index "organization_industries", ["organization_id"], :name => "index_organization_industries_on_organization_id"

  create_table "organization_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "website"
    t.integer  "total_users"
    t.integer  "size_id"
    t.boolean  "is_premium"
    t.boolean  "is_active"
    t.datetime "deleted_at"
    t.integer  "beta_account_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "auth_token"
    t.text     "description"
    t.integer  "organization_type"
    t.integer  "current_sub_id"
    t.integer  "current_user_limit"
    t.integer  "current_storage_limit"
    t.boolean  "is_sub_active",         :default => true
    t.datetime "trial_expires_on"
    t.boolean  "is_trial_expired",      :default => false
    t.integer  "extend_trial_days",     :default => 0
    t.integer  "users_limit",           :default => 10
    t.string   "default_currency",      :default => "US$"
    t.boolean  "is_free_plan",          :default => false
    t.integer  "leads_limit",           :default => 25
    t.integer  "contacts_limit",        :default => 35
    t.integer  "tasks_limit",           :default => 50
    t.integer  "projects_limit",        :default => 2
    t.integer  "proj_tasks_limit",      :default => 20
    t.boolean  "allow_gmail",           :default => false
    t.boolean  "allow_invoice",         :default => false
    t.boolean  "allow_email_tracking",  :default => false
    t.boolean  "allow_web_to_lead",     :default => false
    t.boolean  "change_permissions",    :default => false
    t.string   "short_name"
    t.string   "time_zone"
  end

  create_table "payment_infos", :force => true do |t|
    t.integer  "organization_id"
    t.string   "transaction_id"
    t.float    "amount"
    t.datetime "transaction_date"
    t.string   "last4_digit"
    t.string   "customer_id"
    t.string   "card_holder_name"
    t.string   "street"
    t.string   "city"
    t.string   "country"
    t.string   "zipcode"
    t.string   "payment_token"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "payment_infos", ["organization_id"], :name => "index_payment_infos_on_organization_id"

  create_table "phones", :force => true do |t|
    t.integer  "organization_id"
    t.string   "phone_no"
    t.string   "extension"
    t.string   "phone_type"
    t.string   "phoneble_type"
    t.integer  "phoneble_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "phones", ["organization_id"], :name => "index_phones_on_organization_id"

  create_table "plugin_transactions", :force => true do |t|
    t.integer  "community_plugin_id"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "gmt_offset"
    t.string   "location"
    t.string   "ip"
    t.text     "referrer"
    t.text     "transaction_id"
    t.string   "transaction_status"
    t.integer  "invoice_id"
    t.boolean  "is_emailed"
    t.text     "token"
    t.datetime "download_date"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "download_count",      :default => 0
  end

  create_table "plugins", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "is_active"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "priority_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "original_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "priority_types", ["organization_id"], :name => "index_priority_types_on_organization_id"

  create_table "project_job_groups", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "project_id"
  end

  add_index "project_job_groups", ["organization_id"], :name => "index_project_job_groups_on_organization_id"
  add_index "project_job_groups", ["project_id"], :name => "index_project_job_groups_on_project_id"

  create_table "project_job_repeats", :force => true do |t|
    t.integer  "created_by"
    t.string   "repeat_type"
    t.datetime "repeat_start"
    t.datetime "repeat_end_on"
    t.integer  "repeat_occurrences"
    t.integer  "organization_id"
    t.integer  "project_job_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "project_job_repeats", ["organization_id"], :name => "index_project_job_repeats_on_organization_id"
  add_index "project_job_repeats", ["project_job_id"], :name => "index_project_job_repeats_on_project_job_id"

  create_table "project_job_types", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "original_id"
  end

  add_index "project_job_types", ["organization_id"], :name => "index_project_job_types_on_organization_id"

  create_table "project_jobs", :force => true do |t|
    t.string   "name"
    t.integer  "assigned_to"
    t.integer  "created_by"
    t.string   "priority"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "due_date"
    t.integer  "estimate_hour"
    t.boolean  "is_repeat",             :default => false
    t.string   "notify_email_ids"
    t.string   "status"
    t.integer  "project_job_type_id"
    t.integer  "project_job_group_id"
    t.integer  "individual_contact_id"
    t.integer  "organization_id"
    t.integer  "project_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "is_completed",          :default => false
    t.datetime "resolved_at"
    t.datetime "closed_at"
    t.integer  "progress"
    t.integer  "job_no"
    t.boolean  "catchup_later",         :default => false
    t.integer  "last_updated_by"
    t.boolean  "is_archive",            :default => false
    t.boolean  "is_accessible",         :default => true
    t.boolean  "is_billable"
    t.integer  "project_stage_id"
    t.integer  "estimate_minutes"
    t.string   "contactable_type"
    t.integer  "contactable_id"
    t.string   "event_source"
    t.string   "event_id"
  end

  add_index "project_jobs", ["individual_contact_id"], :name => "index_project_jobs_on_individual_contact_id"
  add_index "project_jobs", ["project_job_group_id"], :name => "index_project_jobs_on_project_job_group_id"
  add_index "project_jobs", ["project_job_type_id"], :name => "index_project_jobs_on_project_job_type_id"

  create_table "project_stages", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.boolean  "is_active"
    t.integer  "position"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "original_id"
  end

  add_index "project_stages", ["organization_id"], :name => "index_project_stages_on_organization_id"

  create_table "project_task_types", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "project_task_types", ["organization_id"], :name => "index_project_task_types_on_organization_id"

  create_table "project_users", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "project_users", ["project_id"], :name => "index_project_users_on_project_id"
  add_index "project_users", ["user_id"], :name => "index_project_users_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.time     "estimate_hour"
    t.integer  "created_by"
    t.string   "status"
    t.text     "description"
    t.integer  "deal_id"
    t.integer  "organization_id"
    t.integer  "individual_contact_id"
    t.integer  "project_task_type_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "is_completed",          :default => false
    t.boolean  "is_archive",            :default => false
    t.boolean  "is_accessible",         :default => true
    t.integer  "project_stage_id"
    t.integer  "project_manager_id"
    t.integer  "company_contact_id"
    t.string   "linked_with"
    t.string   "project_type"
  end

  add_index "projects", ["deal_id"], :name => "index_projects_on_deal_id"
  add_index "projects", ["project_manager_id"], :name => "index_projects_on_project_manager_id"
  add_index "projects", ["project_stage_id"], :name => "index_projects_on_project_stage_id"

  create_table "reminders", :force => true do |t|
    t.integer  "task_id"
    t.integer  "user_id"
    t.boolean  "is_reminder",       :default => false
    t.boolean  "is_reminder_sent",  :default => false
    t.datetime "reminder_datetime"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "reminders", ["task_id"], :name => "index_reminders_on_task_id"
  add_index "reminders", ["user_id"], :name => "index_reminders_on_user_id"

  create_table "resource_distributions", :force => true do |t|
    t.integer  "project_id"
    t.integer  "project_job_id"
    t.integer  "user_id"
    t.datetime "allotted_date"
    t.integer  "allotted_time"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
  end

  add_index "resource_distributions", ["organization_id"], :name => "index_resource_distributions_on_organization_id"
  add_index "resource_distributions", ["project_id"], :name => "index_resource_distributions_on_project_id"
  add_index "resource_distributions", ["project_job_id"], :name => "index_resource_distributions_on_project_job_id"
  add_index "resource_distributions", ["user_id"], :name => "index_resource_distributions_on_user_id"

  create_table "resource_settings", :force => true do |t|
    t.integer  "hours_of_work"
    t.string   "week_off_days"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
  end

  add_index "resource_settings", ["organization_id"], :name => "index_resource_settings_on_organization_id"

  create_table "roles", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "roles", ["organization_id"], :name => "index_roles_on_organization_id"

  create_table "sales_cycles", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "year"
    t.integer  "quarter"
    t.integer  "average"
    t.integer  "shortest"
    t.integer  "longest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "secondary_companies", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "individual_contact_id"
    t.integer  "company_contact_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "secondary_companies", ["company_contact_id"], :name => "index_secondary_companies_on_company_contact_id"
  add_index "secondary_companies", ["individual_contact_id"], :name => "index_secondary_companies_on_individual_contact_id"
  add_index "secondary_companies", ["organization_id"], :name => "index_secondary_companies_on_organization_id"

  create_table "self_hosting_users", :force => true do |t|
    t.string   "license_type"
    t.text     "license_key"
    t.integer  "user_limit"
    t.boolean  "installation_support", :default => false
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "gmt_offset"
    t.string   "location"
    t.string   "ip"
    t.text     "referrer"
    t.text     "transaction_id"
    t.string   "transaction_status"
    t.integer  "invoice_id"
    t.boolean  "is_emailed"
    t.text     "token"
    t.datetime "download_date"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "amount"
    t.integer  "customer_id"
    t.integer  "total_users",          :default => 0
  end

  create_table "sent_email_opens", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.string   "opened"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "obj_id"
    t.string   "obj_type"
    t.integer  "activity_id"
  end

  create_table "sent_emails", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "sent"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "obj_id"
    t.string   "obj_type"
  end

  create_table "smtp_configurations", :force => true do |t|
    t.string   "smtp_host"
    t.string   "port"
    t.string   "email"
    t.string   "user_name"
    t.string   "password"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "sources", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "sources", ["organization_id"], :name => "index_sources_on_organization_id"

  create_table "spam_emails", :force => true do |t|
    t.string   "email"
    t.string   "nickname"
    t.string   "organization_name"
    t.string   "region_name"
    t.string   "city"
    t.string   "country_name"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "ip"
    t.string   "time_zone"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "subscribe_blog_logs", :force => true do |t|
    t.integer  "contact_id"
    t.string   "contact_email"
    t.text     "blog_title"
    t.text     "blog_content"
    t.string   "status"
    t.string   "error_message"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "task_outcomes", :force => true do |t|
    t.string   "name"
    t.string   "task_out_type"
    t.string   "task_duration"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
  end

  create_table "task_priority_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "original_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "task_priority_types", ["organization_id"], :name => "index_task_priority_types_on_organization_id"

  create_table "task_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "original_id"
  end

  add_index "task_types", ["organization_id"], :name => "index_task_types_on_organization_id"

  create_table "tasks", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.integer  "task_type_id"
    t.integer  "assigned_to"
    t.integer  "priority_id"
    t.integer  "deal_id"
    t.datetime "due_date"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "mail_to"
    t.integer  "taskable_id"
    t.string   "taskable_type"
    t.integer  "created_by"
    t.boolean  "is_completed",    :default => false,  :null => false
    t.text     "task_note"
    t.string   "recurring_type",  :default => "none", :null => false
    t.datetime "rec_end_date"
    t.integer  "parent_id"
    t.boolean  "is_event",        :default => false,  :null => false
    t.datetime "event_end_date"
    t.boolean  "is_archive",      :default => false
    t.integer  "archive_by"
    t.boolean  "is_accessible",   :default => true
    t.text     "details"
    t.string   "priority"
    t.string   "status"
    t.string   "event_source"
    t.string   "event_id"
  end

  add_index "tasks", ["organization_id"], :name => "index_tasks_on_organization_id"
  add_index "tasks", ["task_type_id"], :name => "index_tasks_on_task_type_id"

  create_table "temp_contacts", :force => true do |t|
    t.integer  "import_by"
    t.string   "domain"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "name"
    t.string   "gender"
    t.string   "birthday"
    t.string   "relation"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.string   "postcode"
    t.string   "phone_number"
    t.string   "profile_picture"
    t.string   "updated"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "temp_file_uploads", :force => true do |t|
    t.integer  "user_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "temp_images", :force => true do |t|
    t.integer  "user_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "temp_images", ["user_id"], :name => "index_temp_images_on_user_id"

  create_table "temp_leads", :force => true do |t|
    t.integer  "user_id"
    t.text     "title"
    t.string   "priority"
    t.string   "company_name"
    t.string   "company_size"
    t.string   "website"
    t.string   "contact_name"
    t.string   "designation"
    t.string   "phone"
    t.string   "extension"
    t.string   "mobile"
    t.string   "email"
    t.string   "technology"
    t.text     "source"
    t.string   "location"
    t.string   "country"
    t.string   "industry"
    t.text     "comments"
    t.datetime "created_dt"
    t.text     "description"
    t.string   "assigned_to"
    t.string   "facebook_url"
    t.string   "linkedin_url"
    t.string   "twitter_url"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "skype_id"
    t.string   "task_type"
  end

  create_table "temp_projects", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "short_name"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "opportunity"
    t.string   "contact_email"
    t.integer  "estimate_hour"
    t.string   "default_job_type"
    t.text     "description"
    t.string   "team_emails"
    t.boolean  "is_completed"
    t.string   "stage"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "temp_projects", ["organization_id"], :name => "index_temp_projects_on_organization_id"
  add_index "temp_projects", ["user_id"], :name => "index_temp_projects_on_user_id"

  create_table "temp_tables", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "title"
    t.string   "company_name"
    t.string   "web_site"
    t.text     "address"
    t.string   "ref_site"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "country"
    t.integer  "user_id"
    t.text     "note"
    t.string   "first_name"
    t.string   "last_name"
  end

  create_table "user_designations", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "user_designations", ["organization_id"], :name => "index_user_designations_on_organization_id"

  create_table "user_goals", :force => true do |t|
    t.integer  "goal_id"
    t.integer  "user_id"
    t.integer  "deal_id"
    t.string   "amount"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_hourly_billables", :force => true do |t|
    t.integer  "amount"
    t.integer  "organization_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "user_id"
    t.boolean  "is_active",       :default => true
  end

  add_index "user_hourly_billables", ["organization_id"], :name => "index_user_hourly_billables_on_organization_id"

  create_table "user_labels", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "color"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "user_labels", ["organization_id"], :name => "index_user_labels_on_organization_id"
  add_index "user_labels", ["user_id"], :name => "index_user_labels_on_user_id"

  create_table "user_license_requests", :force => true do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.string   "email"
    t.integer  "requested_user_limit"
    t.integer  "amount"
    t.boolean  "is_license_generated", :default => false
    t.text     "new_license_key"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "user_plugins", :force => true do |t|
    t.integer  "user_id"
    t.integer  "plugin_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_plugins", ["plugin_id"], :name => "index_user_plugins_on_plugin_id"
  add_index "user_plugins", ["user_id"], :name => "index_user_plugins_on_user_id"

  create_table "user_preferences", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.boolean  "weekly_digest",         :default => true,     :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "digest_mail_frequency", :default => "weekly"
  end

  add_index "user_preferences", ["user_id"], :name => "index_user_preferences_on_user_id"

  create_table "user_roles", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "user_roles", ["organization_id"], :name => "index_user_roles_on_organization_id"
  add_index "user_roles", ["role_id"], :name => "index_user_roles_on_role_id"

  create_table "user_subscriptions", :force => true do |t|
    t.integer  "subscription_id"
    t.integer  "user_limit"
    t.integer  "storage_limit"
    t.float    "price"
    t.text     "btsubscription_id"
    t.text     "btprofile_id"
    t.text     "cc_token"
    t.string   "payment_status"
    t.boolean  "is_cancel",               :default => false
    t.string   "is_updown"
    t.datetime "subscription_start_date"
    t.datetime "next_billing_date"
    t.datetime "cancel_date"
    t.boolean  "is_active",               :default => true
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "user_subscriptions", ["organization_id"], :name => "index_user_subscriptions_on_organization_id"
  add_index "user_subscriptions", ["user_id"], :name => "index_user_subscriptions_on_user_id"

  create_table "users", :force => true do |t|
    t.integer  "organization_id"
    t.string   "email",                   :default => "",    :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "role_id"
    t.integer  "target"
    t.integer  "admin_type"
    t.string   "encrypted_password",      :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           :default => 0,     :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",         :default => 0,     :null => false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "time_zone"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.boolean  "is_active",               :default => true
    t.datetime "task_date"
    t.string   "digest_mail_date"
    t.integer  "priority_label",          :default => 0,     :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.integer  "gmail_related_id"
    t.boolean  "is_blocked",              :default => false
    t.boolean  "is_disabled",             :default => false
    t.datetime "email_setup_at"
    t.string   "smtp_config"
    t.boolean  "is_email_bounce",         :default => false
    t.integer  "user_designation_id"
    t.integer  "user_hourly_billable_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token", :unique => true
  add_index "users", ["organization_id"], :name => "index_users_on_organization_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "web_forms", :force => true do |t|
    t.integer  "organization_id"
    t.string   "form_unique_id"
    t.string   "form_name"
    t.integer  "user_responsible"
    t.integer  "source_id"
    t.boolean  "is_display_thank_you_page"
    t.string   "external_link"
    t.boolean  "send_email_notification"
    t.text     "field_names"
    t.text     "form_html_code"
    t.integer  "created_by"
    t.boolean  "is_active",                 :default => true
    t.string   "email_to"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "widgets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.boolean  "chart",            :default => true
    t.boolean  "activities",       :default => true
    t.boolean  "feeds",            :default => true
    t.boolean  "tasks",            :default => true
    t.boolean  "usage",            :default => true
    t.boolean  "summary",          :default => true
    t.boolean  "pie_chart",        :default => true
    t.boolean  "column_chart",     :default => true
    t.boolean  "line_chart",       :default => true
    t.boolean  "statistics_chart", :default => true
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "widgets", ["user_id"], :name => "index_widgets_on_user_id"

end

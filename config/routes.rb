SalesCafe::Application.routes.draw do

  get "calendar/index"

  get "track_emails/index"

  get "track_email/index"

  get "project/Task"

  # resources :community_plugins

  match "/contacts/:importer/contact_callback" => 'contacts#contact_callback', :via => [:get, :post]
  match 'import_contacts' => 'contacts#import_contacts', :via => [:get, :post]  
  get 'home/index'

  # start
  get "/auth/google_oauth2" => 'omniauth_callbacks#google_oauth2'
  get "/auth/linkedin/callback" => 'omniauth_callbacks#linkedin'
  get "/auth/:provider/mailbox/callback" => 'emails#create'
  match '/emails' => 'emails#index'
  match '/emails/office' => 'emails#office'
  get 'emails/connect' => 'emails#connect', as: :email_connect
  get 'emails/connect_office' => 'emails#connect_office', as: :email_connect_office
  get '/emails/:provider/mail' => 'emails#mail', as: :email_mail
  get '/emails/:provider/:mailbox/:id' => 'emails#show_email', as: :email_show_email
  post '/emails/:provider/:id/toggle_star' => 'emails#toggle_star'
  post '/emails/:provider/toggle_unread' => 'emails#toggle_unread'
  post '/emails/:provider/delete_emails' => 'emails#delete_emails'
  post '/emails/:provider/send_mail' => 'emails#send_mail', as: :send_email
  post '/emails/:provider/reply_mail' => 'emails#reply_mail', as: :reply_email
  delete '/emails/:provider/logout' => 'emails#logout', as: :email_logout
  match '/auth/failure' => 'emails#failure' 

  match '/auth/office365/callback' => 'auth#gettoken',:as=>"office365_callback"
  get 'authorize' => 'auth#gettoken',:as => 'office365_authorize'
  get 'mail/index' => 'mail#index',:as => 'office365_mails'
  get 'mail/get_mail/:mailbox'=>'mail#get_mail'
  match 'mail/message_read'=>'mail#message_read', :via => [:get, :post]  
  match 'mail/toggle_unread'=>'mail#toggle_unread', :via => [:get, :post]
  get 'mail/connect' => 'mail#connect', as: :mail_connect  
  post 'mail/send_office_mail'=>'mail#send_office_mail', as: :send_office_mail
  post 'mail/reply_office_mail'=>'mail#reply_office_mail', as: :reply_office_mail
  post 'mail/forward_office_mail'=>'mail#forward_office_mail', as: :forward_office_mail
  post 'mail/delete_emails'=>'mail#delete_emails', as: :delete_office_emails
  delete 'mail/logout' => 'mail#logout', as: :office_mail_logout
  match '/create_org' => 'home#create_org', :via => [:post]
  match '/create_org_wizard' => 'home#create_org_wizard', :via => [:post]
  match '/associate_org' => 'home#associate_org', :via => [:post]
  match '/deassociate_company' => 'home#deassociate_company', :via => [:delete]
  match '/connect_contact_to_company' => 'home#connect_contact_to_company', :via => [:post]
  # end
  # match 'users/sign_up' => 'home#index', :via => [:get]
  #devise_for :users, :controllers => {:registrations => 'registrations'}
  #, :omniauth_callbacks => "omniauth_callbacks"

  ################ Getting started urls
  match "/users/gs_save_name" =>"users#gs_save_name",:as=>"gs_save_name"
  match "/users/gs_save_phone_no" =>"users#gs_save_phone_no",:as=>"gs_save_phone_no"
  match "/users/gs_save_address" =>"users#gs_save_address",:as=>"gs_save_address"
  match "/users/gs_save_org_size" =>"users#gs_save_org_size",:as=>"gs_save_org_size"
  match "/users/gs_save_time_zone" =>"users#gs_save_time_zone",:as=>"gs_save_time_zone"
  match "/users/gs_save_org_image" =>"users#gs_save_org_image",:as=>"gs_save_org_image"
  #match "/users/gs_save_org_tmp_image" =>"users#gs_save_org_tmp_image",:as=>"gs_save_org_tmp_image"
  match "/users/gs_save_industries" =>"users#gs_save_industries",:as=>"gs_save_industries"
  match "/users/gs_save_currency" =>"users#gs_save_currency",:as=>"gs_save_currency"
  match "/users/gs_save_sales_stages" =>"users#gs_save_sales_stages",:as=>"gs_save_sales_stages"
  match "/users/gs_save_task_types" =>"users#gs_save_task_types",:as=>"gs_save_task_types"
  match "/users/gs_save_task_outcomes" =>"users#gs_save_task_outcomes",:as=>"gs_save_task_outcomes"
  match "/users/gs_save_lost_reasons" =>"users#gs_save_lost_reasons",:as=>"gs_save_lost_reasons"
  match "/users/gs_save_project_stages" =>"users#gs_save_project_stages",:as=>"gs_save_project_stages"
  match "/users/gs_save_user_roles" =>"users#gs_save_user_roles",:as=>"gs_save_user_roles"
  match "get_user_roles" =>"users#get_user_roles",:as=>"get_user_roles", :via => "get"
  
 





  devise_for :users, :controllers => {:registrations => "registrations",:passwords => "passwords"}, path: '', path_names: { sign_in: 'users/sign-in', sign_up: 'users/sign-up'}
  match '/users/sign_up', to: redirect('/users/sign-up', status: 301)
  match '/users/sign_in', to: redirect('/users/sign-in', status: 301)
  post '/resend_invite', to: 'users#resend_invite', as: 'resend_invite'
  post '/resend_confirmation', to: 'users#resend_confirmation', as: 'resend_confirmation'





  match '/accept_social_invitation/:id', to: 'users#accept_social_invitation', as: 'accept_social_invitation'
  post '/delete_invitation_not_accepted_user', to: 'users#delete_invitation_not_accepted_user', as: 'delete_invitation_not_accepted_user'
  match '/contacts/failure' => 'contacts#import_failure'
  resources :settings
  post 'settings/save_group' => 'settings#save_group'
  post 'settings/delete_group' => 'settings#delete_group'
  post 'settings/delete_label' => 'settings#delete_label'
  post 'settings/get_group' => 'settings#get_group'
  post 'settings/save_source' => 'settings#save_source', :as => 'save_source'
  post 'settings/create_new_source' => 'settings#create_new_source'
  post 'settings/save_industry' => 'settings#save_industry', :as => 'save_industry'
  post 'settings/save_label' => 'settings#save_label', :as => 'save_label'
  post 'settings/save_user_label' => 'settings#save_user_label', :as => 'save_label'
  post 'settings/get_user_label' => 'settings#get_user_label'
  post 'settings/get_task_outcome_label' => 'settings#get_task_outcome_label'
  post 'settings/save_task_outcome_label' => 'settings#save_task_outcome_label'
  post 'settings/delete_taskoutcome' => 'settings#delete_taskoutcome'
  post 'settings/reset_email_setting' => 'settings#reset_email_setting'
  post '/update_organization_currency' => 'settings#update_organization_currency'

  match '/update_weekly_digest' => 'settings#update_weekly_digest', :via => [:get, :post]
  match '/unscribe_latest_blog' => 'settings#unscribe_latest_blog', :via => [:get, :post]
  match 'settings/update_priority_org' => 'settings#update_priority_org', :via => [:get, :post]
  match 'settings/update_lead_status' => 'settings#update_deal_status', :via => [:get, :post]
  match 'settings/update_feed_keyword_org' => 'settings#update_feed_keyword_org', :via => [:get, :post]
  match 'settings/add_lead_stage' => 'settings#add_lead_stage', :via => :post
  match 'settings/update_lead_stages' => 'settings#update_lead_stages', :via => :post
  match 'settings/update_stage_sequence' => 'settings#update_stage_sequence', :via => :post
  match 'settings/update_widget_org' => 'settings#update_widget_org', :via => [:get, :post]
  match 'settings/update_notification' => 'settings#update_notification', :via => [:get, :post]
  match 'settings/add_project_stage' => 'settings#add_project_stage', :via => :post
  match 'settings/update_project_status' => 'settings#update_project_status', :via => [:get, :post]
  match 'settings/update_project_stages' => 'settings#update_project_stages', :via => :post
  match 'settings/get_project_stages' => 'settings#get_project_stages', :via => :post
  match 'settings/add_user_designation' => 'settings#add_user_designation', :via => :post
  match '/settings/update_user_designation' => 'settings#update_user_designation', :via => :post
  match 'delete_user_designation/:id' => 'settings#delete_user_designation'
  match 'settings/add_user_hrly_billable' => 'settings#add_user_hrly_billable', :via => :post
  match '/settings/update_user_hrly_billable' => 'settings#update_user_hrly_billable', :via => :post
  match 'delete_user_hrly_billable/:id' => 'settings#delete_user_hrly_billable'

  match 'settings/fetch_pages' => 'settings#fetch_pages', :via => [:get, :post]
  match '/add_lost_reason' => 'settings#add_lost_reason', :via => [:get, :post]
  match '/update_lost_reason' => 'settings#update_lost_reason', :via => [:get, :post]
  match '/delete_lost_reason/:id' => 'settings#delete_lost_reason', :via => [:get, :post, :delete]

  match 'update_org_settings' => 'settings#update_org_settings'
  match 'get_contacts/:org_id' => 'application#get_contacts'
  match 'settings/edit_source' => 'settings#edit_source'
  match 'settings/edit_industry' => 'settings#edit_industry'
  match 'edit_company_contact/:id' => 'contacts#edit_company_contact'
  match 'edit_individual_contact/:id' => 'contacts#edit_individual_contact'
  match 'edit_ind_contact' => 'contacts#edit_ind_contact'
  match 'getting_started' => 'home#getting_started'
  match 'create_flow_contact' => 'contacts#create_flow_contact'
  match 'daily_updates' => 'home#daily_updates'  
  match 'clear_cache' => 'home#clear_cache'
  match 'load_header_count_section' => 'home#load_header_count_section'
  match 'pie_donut_chart' => 'home#pie_donut_chart'
  match 'line_chart_display' => 'home#line_chart_display'
  match 'summary' => 'home#summary'
  match 'features' => 'home#features'
  match 'lead_statistics_info' => 'home#deal_statistics_info'
  match 'pie_chart_display' => 'home#pie_chart_display'
  match 'funnel_chart_display' => 'home#funnel_chart_display'
  match 'task_widget_page' => 'home#task_widget_page'
  match 'header_user_info' => 'application#header_user_info'
  match 'load_all_partials' => 'application#load_all_partials'
  match 'lead_contacts_info' => 'deals#deal_contacts_info'
  match 'leads_pdf' => 'deals#leads_pdf', :via => [:get, :post]
  match 'leads/setting' => 'deals#deal_setting', :via => [:post]
  match 'created_by_user' => 'deals#created_by_user'
  match 'lead_location_filter' => 'deals#deal_location_filter'
  match 'assigned_lead_leaderboard' => 'deals#assigned_deal_leaderboard'
  match 'upload_multiple_note_attach' => 'deals#upload_multiple_note_attach'
  match 'delete_temp_note_attach' => 'deals#delete_temp_note_attach'
  match 'send_weekly_digest_email' => 'deals#send_weekly_digest_email'
  match 'change_lead_status' => 'deals#change_lead_status'
  match 'get_lead_details_in_lead_listing' => 'deals#get_lead_details_in_lead_listing'
  match 'change_priority' => 'deals#change_priority'
  match 'change_user_label' => 'deals#change_user_label'
  match 'change_deal_source' => 'deals#change_deal_source'
  match 'add_attchment_to_lead' => 'deals#add_attchment_to_lead'
  match 'get_lead_stages' => 'deals#get_lead_stages'
  match 'change_lead_stage' => 'deals#change_lead_stage'
  match 'change_lead_stage_in_lead_details' => 'deals#change_lead_stage_in_lead_details'
  match 'leads/kanban' => 'deals#index'

  match 'projects/kanban' => 'projects#index',:as=>"projects_kanban"
  match '/projects/get_kanban_view' => 'projects#get_kanban_view', :via => [:get, :post]
  match '/project_jobs/get_kanban_view' => 'project_jobs#get_kanban_view', :via => [:get, :post]
  match '/update_project_manager'=>'projects#update_project_manager'
  match 'change_project_status' => 'projects#change_project_status'
  match '/project_widget' => 'projects#project_widget'
  match '/projects/:id/get_project_dependent_data'  => 'projects#get_project_dependent_data'
  # match 'projects/:id' => 'projects#show'
  match 'change_project_job_status' => 'project_jobs#change_project_job_status'
  match '/get_kanban_stages' => 'deals#get_kanban_stages', :via => [:post]
  match 'tab_settings_in_kanban' => 'deals#tab_settings_in_kanban', :via => [:post]
  match 'get_all_activity_users' => 'home#get_all_activity_users'
  match 'filter_activities_by_user' => 'home#filter_activities_by_user'
  match 'generate_company_data' => 'home#generate_company_data'
  match 'get_company_details' => 'home#get_company_details'
  match '/opportunity_widget' => 'deals#opportunity_widget'
  match '/create_email_note' => 'deals#create_email_note'
  match 'update_lead_to_won' => 'deals#update_lead_to_won'
  match 'update_lead_to_lost' => 'deals#update_lead_to_lost'
  match '/update_lead_expected_close_date' => 'deals#update_lead_expected_close_date'
  match '/delete_opportunity_confirm' => 'deals#delete_opportunity_confirm'
  match '/add_lost_reason' => 'settings#add_lost_reason', :via => [:get, :post]
  match '/update_lost_reason' => 'settings#update_lost_reason', :via => [:get, :post]
  match '/delete_lost_reason/:id' => 'settings#delete_lost_reason', :via => [:get, :post, :delete]

  match "leads/:id" => 'deals#update', :via => [:post]
  match "/update_contact_website" => 'contacts#update_contact_website'
  match "/update_contact_phone" => 'contacts#update_contact_phone'
  match "/update_contact_country" => 'contacts#update_contact_country'
  match "/get_contact_country" => 'contacts#get_contact_country'

  authenticated :user do
    root :to => 'home#dashboard'
  end
  devise_scope :user do
    root :to => 'devise/sessions#new'
  end

  match '/notfound' => 'home#notfound'
  match '/activities' => 'home#activities'
  match '/api_contact_us' => 'home#api_contact_us', :via => [:post]
  match 'send_feedback' => 'home#send_feedback'
  get 'dashboard' => 'home#dashboard', :as => 'dashboard'
  get 'organizations' => 'home#organizations', :as => 'organizations'
  match '/get_organizations' => 'home#get_organizations'
  match '/delete_organization' => 'home#delete_organization'
  match '/cancel_organization' => 'subscriptions#cancel', :via => [:post]
  get 'self_hosted_users' => 'home#self_hosted_users', :as => 'self_hosted_users'
  match '/organization/:id/users' => 'users#index'
  match '/task_widget' => 'home#task_widget'
  match '/lead_task_widget' => 'deals#deal_task_widget'
  match '/task_widget_reload' => 'deals#task_widget_reload'
  match '/get_activities' => 'home#get_activities'
  match '/usage' => 'home#usage'
  get 'list_companies' => 'home#list_companies', :as => 'list_companies'
  get '/list_notifications' => 'home#list_notifications', :as => 'list_notifications'
  resources :contacts do
    get :autocomplete_first_name, :on => :collection

  end
  get 'all_contacts' => 'contacts#all_contacts', :as => 'all_contacts'
  match 'add_contact_form' => 'contacts#add_contact_form', :via => [:post]
  match 'get_companies/:org_id' => 'application#get_companies'
  match '/company_contact/:id' => 'contacts#company_contact_detail'
  match 'company_widget' => 'contacts#company_widget'


  match 'company_contact' => 'contacts#company_contact_detail'
  match 'individual_contact' => 'contacts#individual_contact_detail'
  match 'contact/:id' => 'contacts#show_contact_detail'
  match 'change_cont_ownership' => 'contacts#change_cont_ownership'

 
  resources :contacts
  match 'contacts/change_status/:id' => 'contacts#change_status', :via => [:post]
  match 'get_all_contacts' => 'contacts#get_all_contacts', :via => [:GET]
  match 'get_more_contacts' => 'contacts#get_more_contacts', :via => [:post], :as => 'get_more_contacts'
  match 'contact_widget' => 'contacts#contact_widget', :via => [:post]
  match 'get_contact_ajax' => 'contacts#get_contact_ajax', :via => [:post]
  match 'save_contact_timezone' => 'contacts#save_contact_timezone'  
  match 'imported_contacts' => 'contacts#imported_contacts', :via => [:get,:post] 
  match 'import_contact_from_sugar_crm' => 'contacts#import_contact_from_sugar_crm', :via => [:get,:post] 
  match 'import_contact_from_zoho_crm' => 'contacts#import_contact_from_zoho_crm', :via => [:get,:post] 
  match 'import_contact_from_fatfree_crm' => 'contacts#import_contact_from_fatfree_crm', :via => [:get,:post] 
  match 'import_contact_from_other_crm' => 'contacts#import_contact_from_other_crm', :via => [:get,:post] 
  match 'import_bulk_contact' => 'contacts#import_bulk_contact', :via => [:get,:post] 
  match 'imported_bulk_contacts' => 'contacts#imported_bulk_contacts', :via => [:get,:post] 
  match 'proceed_to_bulk_contacts_lead' => 'contacts#proceed_to_bulk_contacts_lead', :via => [:get] 
  match 'fetch_more_contacts' => 'contacts#fetch_more_contacts', :via => [:post], :as => 'get_more_contacts'
  
  match 'proceed_to_lead' => 'contacts#proceed_to_lead', :via => [:get]
  match 'remove_temp_contacts'=> 'contacts#remove_temp_contacts', :via => [:delete]
  match '/create_contact_opportunity' => 'contacts#create_contact_opportunity', :via => [:post]
  match 'opportunity_to_lead/:id' => 'contacts#opportunity_to_lead'  
  match 'update_contact_info' => 'contacts#update_contact_info'  
  match 'change_cont_visibility' => 'contacts#change_cont_visibility'  
  match 'change_opp_visibility' => 'deals#change_opp_visibility' 
  match '/contact_task_widget' => 'contacts#contact_task_widget' 
  
  match 'update_company_info' => 'contacts#update_company_info'  
  match 'get_company_info' => 'contacts#get_company_info'  
  match '/display_company_info' => 'contacts#display_company_info'  
  match '/display_contact_info' => 'contacts#display_contact_info' 
  match 'get_contact_list' => 'contacts#get_contact_list'  
  
  resources :users, :except => [:show]
  match 'get_user_email' => 'users#get_user_email'
  match 'profile' => 'users#profile'
  match 'profile/:id' => 'users#profile'

  match 'delete_selected_contacts' => 'contacts#delete_selected_contacts'
  match '/display_list_view' => 'contacts#display_list_view' , :via => [:get]
  match '/display_grid_view' => 'contacts#display_grid_view' , :via => [:get]
  match 'assign_unassign_deals' => 'users#assign_unassign_deals', :via => [:post]
  match 'get_daily_update_form' => 'deals#get_daily_update_form', :via => [:get]
  match 'save_daily_updates' => 'users#save_daily_updates', :via => [:post]
  match 'manage_daily_updates' => 'users#manage_daily_updates'
  match 'edit_daily_update' => 'users#edit_daily_update'
  match 'delete_daily_update/:id' => 'users#delete_daily_update', :via => [:delete], :as => 'delete_daily_update'
  match '/create_admin_user' => 'users#create_admin_user', :via => [:post]
  match 'users/pricing' => 'users#pricing'

  match '/download_user' => 'home#download_user', :as => 'download_user'
  match 'source_list' => 'users#source_list', :as => 'source_list'
  match 'plugin_integration' => 'users#plugin_integration', :as => 'plugin_integration'
  match 'industry_list' => 'users#industry_list', :as => 'industry_list'
  match '/change_password' => 'users#change_password'
  match '/save_password' => 'users#save_password', :via => [:put]
  match 'invite_user' => 'users#invite_user'
  match 'get_source_list' => 'users#get_source_list', :via => [:post], :as => 'get_source_list'
  match 'get_industry_list' => 'users#get_industry_list', :via => [:post], :as => 'get_industry_list'
  match 'delete_source/:id' => 'users#delete_source'
  match 'delete_industry/:id' => 'users#delete_industry'
  match 'save_profile_info' => 'users#save_profile_info'
  match 'edit_user' => 'users#edit_user'
  match 'assign_deal_to_user' => 'users#assign_deal_to_user'
  match 'resend_invitation' => 'users#resend_invitation'
  match 'load_header_count_user' => 'users#load_header_count_user'
  match 'enable_user/:id' => 'users#enable_usr'
  match 'user_save_tmp_img' => 'users#save_tmp_img'
  match 'update_profile_image' => 'users#update_profile_image'
  match 'block_unblock_user' => 'users#block_unblock_user'
  match 'grant_revoke_admin' => 'users#grant_revoke_admin'
  match 'remove_lead' => 'users#remove_lead'
  match 'get_users' => 'users#get_users'
  match 'enable_disable_user' => 'users#enable_disable_user'
  match 'get_users_dual_list' => 'users#get_users_dual_list'
  match 'update_active_inactive_users' => 'users#update_active_inactive_users', :via => [:post]
  match 'download_back_up_data' => 'users#download_back_up_data'
  resources :contacts do
    get :autocomplete_first_name, :on => :collection
  end

  match 'configure_user_smtp' => 'users#configure_user_smtp'
  match 'setup_email_with_inset' => 'users#setup_email_with_inset'
  resources :tasks
  match 'calendar_task' => 'tasks#calendar_task'
  match 'calendar_data' => 'tasks#calendar_data'
  match 'task_tab_data' => 'tasks#task_tab_data'
  match 'reschedule_task' => 'tasks#reschedule_task'
  match '/delete_task_modal' => 'tasks#delete_task_modal', :via => [:get]

  match 'complete' => 'tasks#complete', :via => [:post]
  match 'edit_task' => 'tasks#edit_task'
  match 'follow_up_task' => 'tasks#follow_up_task'
  match 'start_task' => 'tasks#start_task', :via => [:post]
  match 'all_task' => 'tasks#all_task', :via => [:post]
  match 'today_task' => 'tasks#today_task', :via => [:post]
  match 'overdue_task' => 'tasks#overdue_task', :via => [:post]
  match 'upcoming_task' => 'tasks#upcoming_task', :via => [:post]
  match 'task_listing' => 'tasks#task_listing', :via => [:post]
  match 'task_filter' => 'tasks#task_filter', :via => [:post]
  match 'get_task_details' => 'tasks#get_task_details'
  match 'fetch_tasks' => 'tasks#fetch_tasks', :via => [:get]
  match 'fetch_jobs' => 'project_jobs#fetch_jobs', :via => [:get]

  match 'get_task_type' => 'tasks#get_task_type'
  match 'change_task_type' => 'tasks#change_task_type'

  match '/get_sqllite_task' => 'tasks#get_sqllite_task'
  match 'get_inactive_leads' => 'deals#get_inactive_deals'
  match 'get_lead_opportunity' => 'deals#get_lead_opportunity'
  
  resources :deals, path: :leads, as: :leads
  match '/move_lead' => 'deals#move_lead'
  match 'leads/apply_label_to_lead' => 'deals#apply_label_to_deal', :via => [:post]
  match 'leads/apply_label_to_single_lead' => 'deals#apply_label_to_single_deal', :via => [:post]
  
  match 'get_incoming_leads' => 'deals#get_incoming_deals', :via => [:post], :as => 'get_incoming_leads'
  match 'get_working_on_leads' => 'deals#get_working_on_deals', :via => [:post], :as => 'get_working_on_leads'
  match 'get_won_leads' => 'deals#get_won_deals', :via => [:post], :as => 'get_won_leads'
  match 'get_lost_leads' => 'deals#get_lost_deals', :via => [:post], :as => 'get_lost_leads'
  match 'get_junk_leads' => 'deals#get_junk_deals', :via => [:post], :as => 'get_junk_leads'
  match 'get_un_assigned_leads' => 'deals#get_un_assigned_deals', :via => [:post], :as => 'get_un_assigned_leads'
  match 'get_other_leads' => 'deals#get_other_deals', :via => [:post], :as => 'get_other_leads'

  match 'get_contact' => 'deals#get_contact', :via => [:post]
  match 'edit_lead' => 'deals#edit_deal', :via => [:post]
  match 'delete_selected_leads' => 'deals#delete_selected_deals'
  match 'get_qualify_leads' => 'deals#get_qualify_deals', :via => [:post], :as => 'get_qualify_leads'
  match 'get_not_qualify_leads' => 'deals#get_not_qualify_deals', :via => [:post], :as => 'get_not_qualify_leads'
  match 'get_leads/:org_id' => 'application#get_deals'
  match 'learnmore' => 'deals#learnmore'
  match 'add_contact' => 'deals#add_contact'
  match 'delete_lead_con/:id' => 'deals#delete_deal_con'
  match 'update_lead_ttl' => 'deals#update_deal_ttl'
  match 'update_note_ttl' => 'deals#update_note_ttl'
  match 'fetch_activity' => 'deals#fetch_activity'
  match 'fetch_user_leads' => 'deals#fetch_user_deals'
  match 'fetch_user_jobs' => 'project_jobs#fetch_user_jobs'
  match 'get_industry_list' => 'deals#get_industry_list'
  match 'save_lead_industry' => 'deals#save_deal_industry'
  match '/settings/insert_deal_industry' => 'deals#insert_deal_industry'
  match 'get_country_list' => 'deals#get_country_list', :as => 'get_country_list'
  match 'save_country_lead' => 'deals#save_country_lead', :as => 'save_country_lead'
  match 'get_user_list_lead' => 'deals#get_user_list_lead', :as => 'get_user_list_lead'

  match 'save_user_lead' => 'deals#save_user_lead', :as => 'save_user_lead'
  match 'save_compsize_lead' => 'deals#save_compsize_lead', :as => 'save_compsize_lead'
  match 'quick_lead' => 'deals#quick_deal', :via => [:post]
  match 'change_assigned_to' => 'deals#change_assigned_to', :as => 'change_assigned_to'


  match 'get_task_type_lead' => 'deals#get_task_type_lead', :as => 'get_task_type_lead'
  match 'save_task_type_lead' => 'deals#save_task_type_lead', :as => 'save_task_type_lead'
  match 'accept_lead' => 'deals#accept_assign_deal'
  match 'deny_lead' => 'deals#deny_assign_deal'

  match 'leads_woking_on/:id' => 'deals#deals_woking_on', :via => [:post]
  match 'bulk_lead_upload' => 'deals#bulk_lead_upload', :via => [:post]
  match 'lead_preview' => 'deals#lead_preview', :via => [:get, :post], :except => [:show]
  match 'destroy_lead' => 'deals#destroy_all_lead'
  match 'save_lead' => 'deals#save_lead'
  match 'save_lead_phone' => 'deals#save_lead_phone'
  match 'save_lead_email' => 'deals#save_lead_email'
  match 'save_lead_data' => 'deals#save_lead_data'
  match '/edit_note' => 'deals#edit_note'
  match '/edit_deal_note' => 'deals#edit_deal_note'
  match '/delete_deal_note' => 'deals#delete_deal_note'
  match 'update_deal_note/:id' => 'deals#update_deal_note', :via => [:put]
  match '/add_note_or_attach' => 'deals#add_note_or_attach'
  match '/delete_note_attachment/:id' => 'deals#delete_note_attachment'
  match '/lead_files' => 'deals#deal_files'
  match '/lead_detail_contacts' => 'deals#deal_detail_contacts'
  match 'reassign_user_to_deals' => 'deals#reassign_user_to_deals'
  match '/hide_note' => 'deals#hide_note'

  match 'search_result' => 'search#show'
  match 'search_all' => 'search#search_all'
  resources :search

  match 'fetch_notification_count' => 'home#fetch_notification_count'

  match 'add_notes' => 'application#add_notes', :via => [:post]
  match 'send_email' => 'contacts#send_email', :via => [:get, :post]
  match 'get_extension' => 'application#get_extension'
  match 'get_country_states' => 'application#get_country_states'
  match 'attention_notification' => 'application#attention_notification'
  match 'render_notification_area' => 'application#render_notification_area'
  match '/update_note_type' => 'application#update_note_type', :via => [:put]

  resources :reports
  match 'get_funnel_chart' => 'reports#get_funnel_chart'
  match 'get_user_list_leaderboard' => 'reports#get_user_list_leaderboard'
  match 'get_leads_won' => 'reports#get_deals_won'
  match 'pie_tag_chart' => 'reports#pie_tag_chart'
  match 'report_pdf' => 'reports#report_pdf'
  match 'get_sales_analytic' => 'reports#get_sales_analytic'
  match 'get_lead_report' => 'reports#get_lead_report'
  match 'lead_age_bar_chart' => 'reports#lead_age_bar_chart'

  resources :beta_accounts
  match 'save_user' => 'beta_accounts#save_user'
  match 'new_organization' => 'beta_accounts#new_organization'
  match 'update_organization' => 'beta_accounts#update_organization'
  match 'cancel_organization' => 'beta_accounts#cancel_organization'

  match 'bconfirm' => 'beta_accounts#verify_user'
  match 'approve/:buser_id' => 'beta_accounts#approve'
  match 'disapprove/:buser_id' => 'beta_accounts#disapprove'
  match 'bsignup' => 'home#index'
  match 'email_bounce_notification' => 'home#email_bounce_notification'
  #API routes
  match 'api/createLead' => 'api#createLead', :via => [:post]

  match '/create_web_form_lead' => 'api#create_web_form_lead', :via => [:post]
  match '/send_latest_blog_mail' => 'home#send_latest_blog_mail', :via => [:get, :post]
  match 'delete_stage/:id' => 'settings#delete_stage'
  match 'edit_status' => 'settings#edit_status'
  match '/update_current_lead_status' => 'settings#update_current_lead_status', :via => [:post]
  match '/update_current_project_status' => 'settings#update_current_project_status', :via => [:post]
  match 'settings/update_stage_sequence_in_setting' => 'settings#update_stage_sequence_in_setting', :via => :post
  match 'settings/update_project_stage_sequence_in_setting' => 'settings#update_project_stage_sequence_in_setting', :via => :post
  match 'delete_project_stage/:id' => 'settings#delete_project_stage'
  match '/deals/get_list_view' => 'deals#get_list_view', :via => [:get, :post]
  match '/deals/get_kanban_view' => 'deals#get_kanban_view', :via => [:get, :post]
  match '/deals/get_deal_funnel' => 'deals#get_deal_funnel', :via => [:get, :post]
  match '/deals/create_lead_ticket/:id' => 'deals#create_lead_ticket', :via => [:post]

  match 'user/add_plug_in/:id' => 'users#add_plug_in', :via => [:get, :post]

  match 'delete_lead/:id' => 'deals#delete_lead'
  match 'delete_task_type/:id' => 'settings#delete_task_type'
  match '/update_task_type' => 'settings#update_task_type', :via => [:post]
  match '/add_task_type' => 'settings#add_task_type', :via => [:post]
  match 'find_code_for_javascript' => 'settings#find_code_for_javascript', :via => [:get] 
  match 'enable_api' => 'settings#enable_api', :via => [:post], as: :enable_api
  match 'disable_api' => 'settings#disable_api', :via => [:delete], as: :disable_api
  match '/test_invoice' => 'invoice#test'
  
  match 'invoice/create' => 'invoice#index'
  match 'create_invoice' => 'invoice#create_invoice'
  match 'resend_invoice/:id' => 'invoice#resend_invoice'
  match 'paid_invoice/:id' => 'invoice#paid_invoice'
  match 'cancel_invoice/:id' => 'invoice#cancel_invoice'
  match 'activate_quote/:id' => 'invoice#activate_quote'
  match '/invoice/get_bill_to_details/' => 'invoice#get_bill_to_details', :via => [:post]
  match '/manage_invoice' => 'invoice#manage_invoice'
  match '/invoice_details/:id' => 'invoice#invoice_details'
  match '/invoice_from_quote/:id' => 'invoice#invoice_from_quote'
  match '/download_invoice' => 'invoice#download_invoice', :via => [:GET]
  match '/check_unique_invoice' => 'invoice#check_unique_invoice', :via => [:GET]
  match '/organization/:id/download_invoice/:invoice_id' => 'home#download_invoice', :via => [:GET]

  match '/get_invoice_line_items' => 'invoice#get_invoice_line_items', :via => [:GET]
  match '/get_invoice_deal_projects/' => 'invoice#get_invoice_deal_projects', :via => [:GET]
  
  # Files
  match 'files' => 'files#index'
  match 'get_all_leads' => 'files#get_all_leads'
  match 'filter_files_by_lead' => 'files#filter_files_by_lead'
  match 'load_all_files' => 'files#load_all_files'
  match 'filter_file_on_date_range' => 'files#filter_file_on_date_range'
  match 'get_all_users' => 'files#get_all_users'
  match 'filter_files_by_user' => 'files#filter_files_by_user'
  match 'archive_selected_files' => 'files#archive_selected_files'
  match 'get_all_projects' => 'files#get_all_projects'
  match 'filter_files_by_project' => 'files#filter_files_by_project'
  match 'download_file' => 'files#download_file'
  # resources :community_plugins
  # match 'plugin/:plug_id/checkout' => 'community_plugins#checkout'
  # match 'plugin/:plug_id/pay' => 'community_plugins#pay', :via => [:post]
  # match 'plugin/:token/download' => 'community_plugins#download', :via => [:get]
  

  # match '/emails' => 'emails#index'
  # match '/emails/connect' => 'emails#connect', as: :email_connect
  
  # Website Integration
  match "/web_form/create" => "web_form#new"
  match "/manage_web_form" => "web_form#index"
  match "/create_web_form" => "web_form#create"
  match "/web_form/thank_you" => "web_form#thank_you"
  match "/web_form/generate_form/" => "web_form#generate_form"
  match "web_form/enable_disable_form/:form_unique_id" => "web_form#enable_disable_form"
  match "/get_html_code" => "web_form#get_html_code"

  match '/projects/:project_id/jobs/kanban' => "project_jobs#kanban", :via => [:get]
  match '/project_jobs/kanban' => "project_jobs#kanban", :via => [:get], :as => 'jobs_kanban'
  match '/get_time_log_form' => "project_jobs#get_time_log_form", :via => [:get], :as => 'get_time_log_form'
  match 'job_time_log_create' => "project_jobs#job_time_log_create", :via => [:post], :as => 'job_time_log_create'
  match 'remove_job_time_log' => "project_jobs#remove_job_time_log", :via => [:delete], :as => 'remove_job_time_log'
  match '/get_job_time_logs' => "project_jobs#get_job_time_logs", :via => [:get,:post], :as => 'get_job_time_logs'
  match 'get_job_time_stats' => "project_jobs#get_job_time_stats", :via => [:get], :as => 'get_job_time_stats'
  
  resources :projects do
    resources :project_jobs, path: "jobs" 
    get 'board_view', on: :collection
    get 'details_view', on: :collection
    get 'open_project_popup', on: :collection
    get 'job_listing' => "project_jobs#job_listing"
    post "project_job_repeat" => "project_jobs#job_repeat"
    post "create_comment" => "project_jobs#create_comment", as: "job_comments"
    put "complete_project", on: :collection
    put "complete_mass_project", on: :collection
    put "archive_project", on: :collection
    put "archive_mass_project", on: :collection
    match "get_assigned_to_users", as: "get_assigned_to_users"
    
    
  end
  match 'save_projects' => 'projects#save_projects',:except => [:show]
  match '/change_proj_stage_from_details' => 'projects#change_proj_stage_from_details'
  match '/change_job_status_from_details' => 'project_jobs#change_job_status_from_details'
  match 'get_project_job_types'=> 'projects#get_project_job_types', :via => [:get], :except => [:show]
  match 'get_project_job'=> 'project_jobs#get_project_job', :via => [:get], :except => [:show]
  match 'get_project_stages'=> 'projects#get_project_stages', :via => [:get], :except => [:show]
  match 'save_project_data'=> 'projects#save_project_data', :via => [:get, :post], :except => [:show]
  #match 'project_preview' => 'projects#project_preview', :via => [:get, :post], :except => [:show]
  match 'destroy_temp_project/:id' => 'projects#destroy_temp_project', :via => [:delete],:as=>'destroy_temp_project'
  match 'destroy_all_temp_project' => 'projects#destroy_all_temp_project', :via => [:delete],:as=>'destroy_all_temp_project'
  match 'bulk_project_upload' => 'projects#bulk_project_upload', :via => [:post]
  match 'projects_list' => 'projects#projects_list', :via => [:post], :as => 'projects_list'
  match '/projects/:id/jobs_list' => "project_jobs#jobs_list", :via => [:post], :as => 'jobs_list'
  match '/jobs_list' => "project_jobs#jobs_list", :via => [:post], :as => 'jobs_list'
  
  
  # resource allocation routes
  match 'get_resource_allocation' => 'resource_allocations#get_resource_allocation', :via => [:get], :as => 'get_resource_allocation'
  match 'get_resource_for_reallocation' => 'resource_allocations#get_resource_for_reallocation', :via => [:get], :as => 'get_resource_for_reallocation'
  match '/resource_allocations'=> 'resource_allocations#index',:as=>'resource_allocations'
  match '/resource_utilization'=> 'resource_allocations#resource_utilization',:as=>'resource_utilization'
  match '/get_resource_utilization'=> 'resource_allocations#get_resource_utilization',:as=>'get_resource_utilization'
  match 'reallocate_resource'=> 'resource_allocations#reallocate_resource',:as=>'reallocate_resource'
  match '/weekly_timesheet'=> 'resource_allocations#weekly_timesheet',:as=>'weekly_timesheet'
  match '/get_weekly_timesheet'=> 'resource_allocations#get_weekly_timesheet',:as=>'get_weekly_timesheet'
  match '/weekly_timesheet_save'=> 'resource_allocations#weekly_timesheet_save',:as=>'weekly_timesheet_save',:via=>[:post]

  match "/get_user_list_for_project_job" => "project_jobs#get_user_list_for_project_job"
  match "/change_assign_user_for_job" => "project_jobs#change_assign_user_for_job"
  match "/change_priority_for_project_job" => "project_jobs#change_priority_for_project_job"
  match '/fetch_job_content' => "project_jobs#fetch_job_content"
  match '/update_catchup_later_in_job_details' => "project_jobs#update_catchup_later", :via => [:put]

  match "/job_types" => "project_jobs#job_types"
  match "/create_job_type" => "project_jobs#create_job_type"
  match "/update_job_type" => "project_jobs#update_job_type"



  match "/job_groups" => "project_jobs#job_groups"
  match "/create_job_group" => "project_jobs#create_job_group"
  match "/update_job_group" => "project_jobs#update_job_group"
  
  match "/get_job_types" => "project_jobs#get_job_types"
  match "/update_job_type_in_job_details" => "project_jobs#update_job_type_in_job_details"
  match "/change_status_in_job_details" => "project_jobs#change_status_in_job_details"
  match "/update_job_status" => "project_jobs#update_job_status"
  match "/list_project_job_group" => "project_jobs#list_project_job_group"
  match "/get_project_job_group" => "project_jobs#get_project_job_group"

  match "/update_job_group_in_job_details" => "project_jobs#update_job_group_in_job_details"
  match "/update_job_group_for_job" => "project_jobs#update_job_group_for_job"
  match "/update_job_progress" => "project_jobs#update_job_progress"
  match "/update_estimated_hours" => "project_jobs#update_estimated_hours"
  match "/update_due_date" => "project_jobs#update_due_date"
  
  match '/calendar_view' => 'project_jobs#calendar_view'
  match 'jobs_calendar_data' => 'project_jobs#jobs_calendar_data'
  match 'delete_project_job/:id' => 'project_jobs#destroy', as: "delete_project_job", :via => [:delete]
  match "/update_mass_project_jobs" => "project_jobs#update_mass_project_jobs", :via => [:put]

  match "/update_project_task_type" => "projects#update_project_task_type"
  match "/create_project_task_type" => "projects#create_project_task_type"
  match 'add_project_user' => 'projects#add_project_user'
  match 'update_project_users' => 'projects#update_project_users'
  match 'get_projects_list/:page' => 'projects#get_projects_list'
  match '/get_projects/:org_id' => 'projects#get_projects'
  match 'testgmail' => 'contacts#testgmail' #,:via=>[:post]
  match '/save_goal' => 'settings#save_goal', :via => [:get, :post]
  match '/delete_goal' => 'settings#delete_goal', :via => [:get, :post]
  match '/show_task_detail' => 'tasks#show_task_detail', :via => [:get, :post]
  match '/show_edit_goal' => 'settings#show_edit_goal', :via => [:get, :post]
  match '/edit_goal' => 'settings#edit_goal', :via => [:get, :post]
  
  resources :goals
  match 'goals_view' => 'goals#goals_view', :via => [:get]
  match 'user_goals' => 'goals#user_goals', :via => [:get]
  match '/goals/:user_id' => 'goals#show', :via => [:get]
  match '/goals_by_user/:user_id' => 'goals#goals_by_user', :via => [:get]
  # resources :community_plugins
  # match 'plugin/:plug_id/checkout' => 'community_plugins#checkout'
  # match 'plugin/:plug_id/pay' => 'community_plugins#pay', :via => [:post]
  # match 'plugin/:token/download' => 'community_plugins#download', :via => [:get]
  
  # match '/emails' => 'emails#index'
  # match '/emails/connect' => 'emails#connect', as: :email_connect
  
  # Website Integration
  match "/web_form/create" => "web_form#new"
  match "/manage_web_form" => "web_form#index"
  match "/create_web_form" => "web_form#create"
  match "/web_form/thank_you" => "web_form#thank_you"
  match "/web_form/generate_form/" => "web_form#generate_form"
  match "web_form/enable_disable_form/:form_unique_id" => "web_form#enable_disable_form"
  match "/get_html_code" => "web_form#get_html_code"
  match "calendar" => "calendar#index"
  match "get_all_calendar_data" => "calendar#get_all_calendar_data"
  match "edit_calendar_event" => "calendar#edit_calendar_event"
  match "delete_calendar_event" => "calendar#delete_calendar_event"
  
  match '/404', to: 'errors#error_404', via: :all
  match '/422', to: 'errors#error_422', via: :all
  match '/500', to: 'errors#error_500', via: :all 
end

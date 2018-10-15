# == Schema Information
#
# Table name: organizations
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  email                 :string(255)
#  website               :string(255)
#  total_users           :integer
#  size_id               :integer
#  is_premium            :boolean
#  is_active             :boolean
#  deleted_at            :datetime
#  beta_account_id       :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  auth_token            :string(255)
#  description           :text
#  organization_type     :integer
#  current_sub_id        :integer
#  current_user_limit    :integer
#  current_storage_limit :integer
#  is_sub_active         :boolean          default(TRUE)
#  trial_expires_on      :datetime
#  default_currency      :string(255)      default("US$")
#  users_limit           :integer          default(10)
#  is_trial_expired      :boolean          default(FALSE)
#  extend_trial_days     :integer          default(0)
#  is_free_plan          :boolean          default(FALSE)
#  leads_limit           :integer          default(25)
#  contacts_limit        :integer          default(35)
#  tasks_limit           :integer          default(50)
#  projects_limit        :integer          default(2)
#  proj_tasks_limit      :integer          default(20)
#  allow_gmail           :boolean          default(FALSE)
#  allow_invoice         :boolean          default(FALSE)
#  allow_email_tracking  :boolean          default(FALSE)
#  allow_web_to_lead     :boolean          default(FALSE)
#  change_permissions    :boolean          default(FALSE)
#  short_name            :string(255)
#  time_zone             :string(255)
#

class Organization < ActiveRecord::Base
  attr_accessible  :beta_account_id, :deleted_at, :email, :is_active, :is_premium, :name, :size_id, :total_users, :website,:company_strength,:users,:description,:address_attributes,:phone_attributes,:auth_token, :organization_type,:current_sub_id ,:is_sub_active , :current_user_limit,:trial_expires_on, :is_trial_expired , :user_allowed_by_admin, :extend_trial_days, :users_limit, :leads_limit, :contacts_limit, :tasks_limit, :projects_limit, :proj_tasks_limit, :allow_gmail, :allow_invoice, :allow_email_tracking, :allow_web_to_lead, :change_permissions, :is_free_plan, :default_currency,:short_name,:company_industry_id,:deal_statuses,:time_zone
  
  has_many :priority_types, :dependent => :destroy
  has_many :deal_statuses, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  has_many :individual_contacts, :dependent => :destroy
  has_many :company_contacts, :dependent => :destroy
  has_many :sources, :dependent => :destroy
  has_many :deals, :dependent => :destroy
  has_many :deals_contacts, :dependent => :destroy
  has_many :task_types, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :industries, :dependent => :destroy
  has_many :deal_moves, :dependent => :destroy
  has_many :deal_transactions, :dependent => :destroy
  has_many :attachments, :class_name => "Note",:dependent => :destroy
  has_many :roles, :dependent => :destroy
  has_many :attention_deals, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :deal_industries, :dependent => :destroy
  has_many :user_preferences, :dependent => :destroy
  has_many :user_labels, :dependent => :destroy
  has_many :deal_sources, :dependent => :destroy
  has_many :web_forms, :dependent => :destroy
  has_many :mail_letters, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  has_many :project_jobs, :dependent => :destroy
  has_many :project_task_types, :dependent => :destroy
  has_many :project_job_types, :dependent => :destroy
  has_many :project_job_groups, :dependent => :destroy
  has_many :note_types, :dependent => :destroy
  has_many :lost_reasons, :dependent => :destroy
  has_many :smtp_configurations
  has_many :expiry_notifications
  has_many :goals
  has_many :organization_industries
  #has_many :feed_keywords, :dependent => :destroy
  belongs_to :company_strength,:class_name=>"CompanyStrength",:foreign_key=>"size_id"

  has_many :task_priority_types , :dependent => :destroy
  has_many :api_integrations, dependent: :destroy
  has_one :address, :as => :addressable,:class_name=>"Address", :dependent => :destroy
  has_one :phone, :as => :phoneble,:class_name=>"Phone", :dependent => :destroy
  has_many :user_subscriptions
  has_many :transactions
  has_many :feedbacks
  has_many :project_stages
  has_one :image, :as => :imagable, :dependent => :destroy
  has_many :user_designations, :dependent => :destroy
  has_many :user_hourly_billables, :dependent => :destroy
  #callback to save some default data while creating organizations
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :phone
  accepts_nested_attributes_for :image
  after_create :insert_default_data
  # after_save :inactive_org_users, :if => :is_trial_expired_changed?
  # after_save :inactive_org_users, :if => :is_sub_active_changed?
  
  has_many :users,:foreign_key=>"organization_id", :dependent => :destroy
  has_many :invoices, :dependent => :destroy
  has_many :email_series, :foreign_key=>"org_id", :dependent => :destroy
  has_one :resource_setting, :dependent => :destroy
  has_many :job_time_logs
  has_many :resource_distributions
  has_many :task_outcomes
  attr_accessor :street, :state, :country, :city, :zip,:phone_no
  accepts_nested_attributes_for :organization_industries
  accepts_nested_attributes_for :task_types , reject_if: proc { |attributes| attributes['name'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :deal_statuses , reject_if: proc { |attributes| attributes['name'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :task_outcomes , reject_if: proc { |attributes| attributes['name'].blank? || attributes['task_out_type'].blank? || attributes['task_duration'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :lost_reasons , reject_if: proc { |attributes| attributes['reason'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :project_stages , reject_if: proc { |attributes| attributes['name'].blank? ||  attributes['is_active'].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :project_stages , reject_if: proc { |attributes| attributes['name'].blank? ||  attributes['is_active'].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :roles , reject_if: proc { |attributes| attributes['name'].blank?}, :allow_destroy => true
  

  def insert_default_data 
    begin
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx'
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx'
    p 'Organization Created'
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx'
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx'
    
    puts ">>>>>>>>>>           1        <<<<<<<<<<<<<<<<<<"
    self.user_labels.create(name: "Inbound")
    self.user_labels.create(name: "Outbound")
    self.user_labels.create(name: "Uncategorised")
    puts ">>>>>>>>>>           2        <<<<<<<<<<<<<<<<<<"
    
    #Update auth_token where auth_token is nil
    auth_key = "#{self.id}-#{self.name}-#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
    puts ">>>>>>>>>>           3        <<<<<<<<<<<<<<<<<<"
    
    self.update_column :auth_token, Base64::strict_encode64(auth_key)
    puts ">>>>>>>>>>           4        <<<<<<<<<<<<<<<<<<"
    
    # Default lead status for organization
    @deal_status = DealStatus.where(:organization_id => 1)
    @deal_status.each do |deal_status|
      DealStatus.create(name: deal_status.name, original_id: deal_status.original_id, organization_id: self.id)
    end
    puts ">>>>>>>>>>           5        <<<<<<<<<<<<<<<<<<"
    
    #1 - Hot, 2 - Warm, 3 - cold 
    priority = {"1" => "Hot", "2" => "Warm", "3" => "Cold"}   
    priority.each_pair do |key, value|    
      PriorityType.create :organization_id => self.id, :original_id => key, :name => value
    end 
    puts ">>>>>>>>>>           6        <<<<<<<<<<<<<<<<<<"
     
   
    #deafult task types for organization
    task_types = ["Appointment","Billing","Call","Documentation","Email","Follow-up","Meeting","None","Quote","Thank-you"]
    task_types.each do |task_name|
        TaskType.create :organization_id => self.id, :name => task_name
    end
    puts ">>>>>>>>>>           7        <<<<<<<<<<<<<<<<<<"
    
    #deafult note types for organization
    note_types = ["Follow-Up","Suggestion","Reminder","Conversation","Files","Quote"]
    note_types.each do |note_type|
        NoteType.create :organization_id => self.id, :name => note_type
    end
    puts ">>>>>>>>>>           8        <<<<<<<<<<<<<<<<<<"
    
    ##1 - New Deals, 2 - Qualified, 3 - Not Qualified, 4 - Won, 5 - Lost, 6 - Junk 
    #commented for new deal stages
    #priority = {"1" => "New Deals", "2" => "Qualified", "3" => "Not Qualified", "4" => "Won", "5" => "Lost", "6" => "Junk"}
    #priority.each_pair do |key, value|    
    #  DealStatus.create :organization_id => self.id, :original_id => key, :name => value
    #end
    # deal_stages = DealStage.all
    # deal_stages.each do |dealstage|
    #   DealStatus.create :organization_id => self.id, :original_id => dealstage.original_id, :name => dealstage.name
    # end
	
    ##deafult roles for organization
    roles = ["Sales","Lead Generator"]
    roles.each do |role_name|
        Role.create :organization_id => self.id, :name => role_name
    end
    puts ">>>>>>>>>>           9        <<<<<<<<<<<<<<<<<<"
    
    self.update_column :trial_expires_on, Time.now+30.days
    puts ">>>>>>>>>>           10        <<<<<<<<<<<<<<<<<<"
    

    individual_contact = self.individual_contacts.create(first_name: "Johny", last_name:"Roberts", email: "johny.roberts@email.com", country_id: 236)
    puts ">>>>>>>>>>           11        <<<<<<<<<<<<<<<<<<"
        
    priority_type = self.priority_types.find_by_name("Hot")
    puts ">>>>>>>>>>           12        <<<<<<<<<<<<<<<<<<"
    user_label = self.user_labels.find_by_name("Inbound")
    puts ">>>>>>>>>>           13        <<<<<<<<<<<<<<<<<<"
    deal_status = self.deal_statuses.find_by_name("Qualified")
    puts ">>>>>>>>>>           14        <<<<<<<<<<<<<<<<<<"
    # deal = self.deals.create(title: "(Sample Data) Tourism Inquiry", priority_type_id: priority_type.id, amount:"8999" , deal_status_id: deal_status.id, country_id: 236 , contact_info: {"name"=>"Johny Roberts", "id"=>individual_contact.id, "type"=>"individual_contact", "phone"=>"", "email"=>"johny.roberts@email.com"}, is_active: true, initiated_by: self.users.first )
    # puts ">>>>>>>>>>           15        <<<<<<<<<<<<<<<<<<"
    # deal.update_column :user_label_id, user_label.id
    # puts ">>>>>>>>>>           16        <<<<<<<<<<<<<<<<<<"
    # DealsContact.create(:organization_id => self.id, deal_id: deal.id, contactable_type: "IndividualContact", contactable_id: individual_contact.id)
    # puts ">>>>>>>>>>           17        <<<<<<<<<<<<<<<<<<"
    
    
    # individual_contact = self.individual_contacts.create(first_name: "David", last_name:"Simpson", email: "simpson.david@email.com", country_id: 40)
    puts ">>>>>>>>>>           18        <<<<<<<<<<<<<<<<<<"
    priority_type = self.priority_types.find_by_name("Warm")
    puts ">>>>>>>>>>           19        <<<<<<<<<<<<<<<<<<"
    user_label = self.user_labels.find_by_name("Outbound")
    puts ">>>>>>>>>>           20        <<<<<<<<<<<<<<<<<<"
    deal_status = self.deal_statuses.find_by_name("New")
    # puts ">>>>>>>>>>           21        <<<<<<<<<<<<<<<<<<"
    # deal = self.deals.create(title: "(Sample Data) Website Development", priority_type_id: priority_type.id, amount:"2999" , deal_status_id: deal_status.id, country_id: 40 , contact_info: {"name"=>"David Simpson", "id"=>self.individual_contacts.last.id, "type"=>"individual_contact", "phone"=>"", "email"=>"simpson.david@email.com"}, is_active: true, initiated_by: self.users.first )
    # puts ">>>>>>>>>>           22        <<<<<<<<<<<<<<<<<<"
    # deal.update_column :user_label_id, user_label.id
    # puts ">>>>>>>>>>           23        <<<<<<<<<<<<<<<<<<"
    # DealsContact.create(:organization_id => self.id, deal_id: deal.id, contactable_type: "IndividualContact", contactable_id: individual_contact.id)
    # puts ">>>>>>>>>>           24        <<<<<<<<<<<<<<<<<<"
    
    ## Insert Resource Setting
      rs =ResourceSetting.new
      rs.organization_id = self.id
      rs.hours_of_work=8
      rs.week_off_days=[0,6]
      rs.save
      puts ">>>>>>>>>>           25        <<<<<<<<<<<<<<<<<<"
    ## Insert default project stage
    ProjectStage.create(:organization_id=>self.id,  :is_active=>true, :name => 'New', :position=>1,:original_id=>1)
    ProjectStage.create(:organization_id=>self.id,  :is_active=>true, :name => 'Completed', :position=>2,:original_id=>2)
    puts ">>>>>>>>>>           26        <<<<<<<<<<<<<<<<<<"
    puts "create default administrative project"
    super_admin= get_super_admin
    if(super_admin.present?)
      Project.create(:organization_id=>self.id,  :is_accessible=>true, :name=>"Administrative",:short_name=>"Admin",:description=>'All Administrative Tasks',:project_type=>'Administrative',:project_manager_id => super_admin.id,:created_by => super_admin.id,:status =>"Started")
    end

    rescue => ex
      p ex.message
    end
  end  
  ### Export CSV ###
  def self.to_csv
    CSV.generate do |csv|
      csv << ["Org. Name", "Email", "Date Signed Up", "Plan", "Location", "Google/Linkedin/Regular sign up", "Last activity date", "No of user invited"] ## Header values of CSV
      all.last(2)
      all.each do |org|
        google_users = org.users.select {|r| r.provider.include?("google") if r.provider.present? }.count
        linkedin_users = org.users.select {|r| r.provider.include?("linkedin") if r.provider.present? }.count
        regular_users = org.users.select {|r| r.provider.nil? }.count
        if (super_admin = org.users.where("admin_type=?",1).first).present?
          result = Geocoder.search(super_admin.last_sign_in_ip)
          geo_data  = result.first.data if result.present? && result.first.present?
          location = geo_data["country_name"] if geo_data.present?
        end
        csv << [org.name.present? ? org.name : "NA",
                org.email.present? ? org.email : (org.users.present? ? org.users.first.email : "NA"),
                org.created_at.strftime("%b %d, %Y"),
                org.get_plan,
                location.present? ? location : "NA",
                "Google (" + google_users.to_s + "), Linkedin (" + linkedin_users.to_s + "), Regular (" + regular_users.to_s + ")",
                org.activities.present? ? org.activities.last.created_at.strftime("%b %d, %Y") : "NA",
                org.users.present? ? (org.users.count - 1) : 0 ] ##Row values of CSV
      end
    end
  end
  # def inactive_org_users
  #    puts "-------------------> inactive_org_users"
  #    p self.is_trial_expired
  #    p self.is_sub_active
  #    p self.is_trial_expired || self.is_sub_active
  #    if self.is_trial_expired || self.is_sub_active
  #     self.users.where(["admin_type not in (?)", [0,1]]).update_all is_active: false
  #    end

  #    # sssssssssssssss
  # end 

  def hot_priority
    return self.priority_types.find(:first,:conditions=>["original_id = ? ",1])
  end
  def warm_priority
    return self.priority_types.find(:first,:conditions=>["original_id = ? ",2])
  end
  def cold_priority
    return self.priority_types.find(:first,:conditions=>["original_id = ? ",3])
  end
  def get_deal_status(original_id)
    dlstatus= self.deal_statuses.where("original_id = ?",original_id)
    return dlstatus
  end
  def filter_deal_status(deal_status,org_id)
   deal_status = DealStatus.get_deal_name(deal_status,org_id)
   return deal_status
   #return  self.deal_statuses.where("original_id = 1").first
  end
  def incoming_deal_status
   return  self.deal_statuses.where("original_id = 1").first
  end
  def qualify_deal_status
   return  self.deal_statuses.where("original_id = 2").first
  end
  def not_qualify_deal_status
   #return  self.deal_statuses.where("original_id = 3").first
   return  self.deal_statuses.where("name = ?", "Not Qualified").first
  end
  def won_deal_status
   return  self.deal_statuses.where("original_id = 4").first
  end
  def lost_deal_status
   return  self.deal_statuses.where("original_id = 5").first
  end
  def junk_deal_status
   return  self.deal_statuses.where("original_id = 6").first
  end
  #Added new deal statuses
  def no_contact_deal_status
   return  self.deal_statuses.where("original_id = 7").first
  end
  def follow_up_required_deal_status
   return  self.deal_statuses.where("original_id = 8").first
  end
  def follow_up_deal_status
   return  self.deal_statuses.where("original_id = 9").first
  end
  def quoted_deal_status
   return  self.deal_statuses.where("original_id = 10").first
  end
  def meeting_scheduled_deal_status
   return  self.deal_statuses.where("original_id = 11").first
  end
  def forecasted_deal_status
   return  self.deal_statuses.where("original_id = 12").first
  end
  def waiting_for_project_requirement_deal_status
   return  self.deal_statuses.where("original_id = 13").first
  end
  def proposal_deal_status
   return  self.deal_statuses.where("original_id = 14").first
  end
  def estimate_deal_status
   return  self.deal_statuses.where("original_id = 15").first
  end 
  def get_deal_status(status_type)
    case status_type
      when 'new','incoming','lead'
        ds = self.deal_statuses.where("original_id = 1").first
      when 'pipeline','qualify'
        ds = self.deal_statuses.where("original_id = 2").first
      when 'won'
        ds = self.deal_statuses.where("original_id = 3").first
      when 'lost'
        ds = self.deal_statuses.where("original_id = 4").first
      when 'not_qualify'
        ds = self.deal_statuses.where("original_id = 5").first
      when 'junk','dead'
        ds = self.deal_statuses.where("original_id = 6").first
      when 'nocontact','no_contact'
        ds = self.deal_statuses.where("original_id = 7").first
      when 'follow_up_required'
        ds = self.deal_statuses.where("original_id = 8").first
      when 'follow_up'
        ds = self.deal_statuses.where("original_id = 9").first
      when 'quoted'
        ds = self.deal_statuses.where("original_id = 10").first
      when 'meeting_scheduled'
        ds = self.deal_statuses.where("original_id = 11").first
      when 'forecasted'
        ds = self.deal_statuses.where("original_id = 12").first
      when 'waiting_for_project_requirement'
        ds = self.deal_statuses.where("original_id = 13").first
      when 'proposal'
        ds = self.deal_statuses.where("original_id = 14").first
      when 'estimate'
        ds = self.deal_statuses.where("original_id = 15").first
    end
  end

  def self.organization_list
    includes(:activities).select("id, name, email, created_at, total_users, is_trial_expired, change_permissions, is_free_plan").order("created_at desc")
  end
  
  def get_location
    location=""
    if (address = self.address).present?
      location += address.address + ", " if address.address.present?
      location += address.city + ", " if address.city.present?
      location += address.state + ", " if address.state.present?
      location += address.country.name if address.country.present?
    end
    return location
  end

  # Retrive all Attachments of current organization
  def all_attachments notes=nil
    if notes == nil
      notes = self.notes.collect{|note| note.id}
      NoteAttachment.where(note_id: notes, is_archive:false).order("id DESC")
    else
      NoteAttachment.where(note_id: notes, is_archive:false).order("id DESC")
    end
  end

  def trail_days_left_in_words
    # t = ((((self.trial_expires_on.to_datetime)-Time.now.to_datetime)/(24.0*60*60)).round)
    t = ((DateTime.parse(self.trial_expires_on.to_s) - DateTime.parse(Time.now.to_s))).to_i
    case t 
    when 0
      "Trial will expire today"
    else
      t == 1 ? "#{t} day trial left" : "#{t} days trial left"
    end
  end

  def trail_days_left_in_days
    t = ((DateTime.parse(self.trial_expires_on.to_s) - DateTime.parse((Time.now).to_s))).to_i
    return t
  end

  def active_users
    self.users.where("invitation_token IS ?", nil).where("is_active = ? and is_disabled =? and is_blocked = ?", true,false,false)
  end
  def is_professional?
    return user_subscriptions.present? && user_subscriptions.active.present?
  end
  def get_plan
    if is_professional?
      plan = "Pro plan"
    elsif user_subscriptions.present? && !user_subscriptions.active.present?
      plan = "Pro plan Expired"
    elsif !trial_expired?
      plan = "Trial"
    elsif is_trial_period_expired?
      plan = "Trial Expired"
    else
      plan = "Free"
    end
    return plan
  end
  def is_visible_pro?
    current_sub = self.user_subscriptions
    if (current_sub.present? && current_sub.active.present?) || !self.trial_expired? || (self.trial_expires_on.to_date < Time.now.to_date && self.extend_trial_days == 1)
      return false
    elsif current_sub.present? && (active_sub=current_sub.active).present?
      if (active_sub.last.is_grace_active.present? && (Time.now.to_date <= active_sub.last.grace_period_ends_on.to_date)) || (Time.now.to_date <= active_sub.last.next_billing_date.to_date)
        return false
      else
        return true
      end
    else
      return true
    end 
  end
  def trial_expired?
    self.is_trial_expired
  end
  def admins
    self.users.where("admin_type in ( 1, 2)").all
  end
  def get_super_admin
    self.users.where("admin_type=?",1).first
  end
  def active_project_stages
    self.project_stages.where(:is_active=>true)
  end
end

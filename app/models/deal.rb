# == Schema Information
#
# Table name: deals
#
#  id                    :integer          not null, primary key
#  organization_id       :integer
#  title                 :string(255)
#  priority_type_id      :integer
#  assigned_to           :integer
#  contact_id            :integer
#  tags                  :string(255)
#  amount                :float
#  probability           :integer
#  attempts              :integer
#  is_public             :boolean          default(TRUE)
#  initiated_by          :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  deal_status_id        :integer
#  is_active             :boolean
#  is_current            :boolean
#  country_id            :integer
#  is_csv                :boolean          default(FALSE)
#  is_mail_sent          :boolean          default(TRUE)
#  closed_by             :integer
#  last_activity_date    :datetime
#  comments              :text
#  is_remote             :boolean          default(FALSE)
#  app_type              :string(255)
#  latest_task_type_id   :integer
#  contact_info          :text
#  stage_move_date       :datetime
#  duration              :string(255)
#  billing_type          :string(255)
#  is_opportunity        :boolean          default(FALSE), not null
#  payment_status        :string(255)      default("Not done")
#  referrer              :string(255)
#  hot_lead_token        :text
#  token_expiry_time     :datetime
#  next_priority_id      :integer
#  assignee_id           :integer
#  visited               :text
#  location_by_api       :text
#  individual_contact_id :integer
#  user_label_id         :integer          default(1)
#  web_form_id           :integer
#  is_project            :boolean          default(FALSE)
#  project_id            :integer
#  deactivated_by        :integer
#  is_accessible         :boolean          default(TRUE)
#  currency_type         :string(255)      default("US$")
#  is_won                :boolean
#  lost_reason           :text
#  lost_comment          :text
#  custom_value          :string(255)
#  closed_date           :datetime
#  expected_close_date   :datetime
#  ref_billing_amount    :float
#

class Deal < ActiveRecord::Base
  include ApplicationHelper
  include EncryptedId
  belongs_to :organization
  belongs_to :priority_type
  belongs_to :contact, :class_name=>"Contact"
  belongs_to :individual_contact, :foreign_key=> "contact_ref_id"
  # belongs_to :company_contact, :foreign_key=> "contact_ref_id"
  belongs_to :assigned_user, :class_name=>"User",:foreign_key=>"assigned_to"
  belongs_to :initiator, :class_name=>"User",:foreign_key=>"initiated_by"
  #belongs_to :assigned_to, :class_name=>"User",:foreign_key=>"assigned_to"
  has_one :deal_source, :class_name=>"DealSource"
  has_one :deal_industry, :class_name=>"DealIndustry"
  has_one :daily_update, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  #has_many :attachments,:class_name=>"Note",:as=>:notable
  belongs_to :deal_status,:class_name=>"DealStatus"
  has_many :tasks, :dependent => :destroy
  has_many :deal_labels
  has_many :deal_moves
  has_many :deal_transactions, :dependent => :destroy
  has_many  :deals_contacts, :dependent => :destroy
  has_many :activities, :class_name=>"Activity", :dependent => :destroy, :as=>:source # :foreign_key=>"source_id"
  has_many :mail_letters, :as => :mailable
  has_many :invoices, :dependent => :destroy
  belongs_to :current_country, :class_name=>"Country",:foreign_key=>"country_id"
  belongs_to :last_task, :class_name=>"TaskType",:foreign_key=>"latest_task_type_id"
  belongs_to :user_label
  belongs_to :web_form
  serialize :contact_info, JSON
  
  #include Tire::Model::Search
  #include Tire::Model::Callbacks

  attr_accessible :is_current,:is_active,:contact,:amount, :attempts, :initiated_by, :is_public, 
          :probability, :title, :assigned_to, :priority_type,:deal_status_id,:deal_status,:created_at, :is_csv, :is_mail_sent,
          :last_activity_date, :comments,:latest_task_type_id, :contact_info, :duration, :billing_type, 
          :stage_move_date, :tag_list, :hot_lead_token, :token_expiry_time, :next_priority_id, :assignee_id, :is_remote,:payment_status,:referrer,:visited,:location_by_api, :individual_contact_id, :user_label_id, :priority_type_id, :country_id, :web_form_id, :is_project, :project_id, :deactivated_by, :currency_type, :is_won, :lost_reason, :closed_date, :expected_close_date, :lost_comment, :is_webtolead, :closed_by, :ref_billing_amount, :custom_value

          
  attr_accessor :work_phone,:contact_id,:file_description,
    :created_by, :email, :facebook_url, :first_name, :last_name, :linkedin_url, :messanger_id, 
    :messanger_type, :name, :twitter_url, :website,:company_strength_id,:contact_type,
    :address,:city,:state,:zip_code,:mobile_number,:image,:notes,:company_strength,:full_address,:monthly_avg, :move_deal,:activities_count, :source_id, :industry_id
  acts_as_taggable
    
  #after_create :send_email,:insert_deal_activity
  # after_create :insert_deal_activity
  after_create :insert_count_company_contacts, :send_mailto_assigned_user
  after_save :update_country_id, :add_stages_to_transaction
  after_save :update_stage_move_date, :if => :deal_status_id_changed?
  after_update :create_deal_status_activity, :if => :deal_status_id_changed?
  after_update :create_won_lost_activity, :if => :is_won_changed?
  after_update :reassign_actvity, :send_mailto_assigned_user, :if => :assigned_to_changed?
  after_update :create_activity
  after_update :update_amount, :if => :amount_changed?
  after_update :update_count_company_contact, :if => :is_won_changed?

#  before_create :update_stage_move_date
  before_save :set_tag_owner #, :if => :deal_tag_list_changed?
  before_destroy :delete_count_company_contacts
  
  default_scope where(:is_accessible => true)
  scope :by_label, lambda{|type|joins(:deal_labels).where("user_label_id   = ? ", type)}  
  scope :by_priority, lambda{|type| where("priority_type_id   = ? ", type)}  
  scope :by_stage, lambda{|type| where("deal_status_id   = ? ", type)}  
  scope :by_is_active, lambda {where("is_active = ?", true)}  
  scope :within_four_weeks, lambda{ where('deals.created_at >= ?', 4.weeks.ago)}  
  scope :in_last_month, lambda{ where(:created_at => 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :in_current_month, lambda{ where('deals.created_at BETWEEN ? AND ?', DateTime.now.in_time_zone.beginning_of_month, DateTime.now.in_time_zone.end_of_month) }
  scope :created_and_assigned, lambda{|id| where("initiated_by = ? or assigned_to = ?", id,id)}
  scope :by_range, lambda{ |start_date, end_date| where(:created_at => start_date..end_date) }
  scope :last_three_months, lambda{ where('deals.created_at >= ?', 3.months.ago)}  
  encrypted_id key: '6476b3f5ec6dcaddb637e9c9654aa687'

  def insert_user_label
    self.update_column :user_label_id, self.organization.user_labels.where("name = ?", "Inbound")
  end
  def insert_count_company_contacts
    puts "test 22222222222..................................."
    if self.deals_contacts.present? && self.deals_contacts.first.contactable.present? && (cc=self.deals_contacts.first.contactable.class.name == "IndividualContact" ? self.deals_contacts.first.contactable.company_contact : self.deals_contacts.first.contactable).present?
      cc.increment!(:total_opportunities, 1)
      cc.increment!(:total_open_opportunities, 1)
    end
  end
  def delete_count_company_contacts
    puts "test ..................................."
    if self.deals_contacts.present? && self.deals_contacts.first.contactable.present? && self.deals_contacts.first.contactable.present? && (cc=self.deals_contacts.first.contactable.class.name == "IndividualContact" ? self.deals_contacts.first.contactable.company_contact : self.deals_contacts.first.contactable).present?
      cc.decrement!(:total_opportunities, 1)
      cc.update_column(:total_open_opportunities, cc.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten.select{|d| (d.is_won == nil || d.is_won == "") && d.is_active}.count)
    end
  end
  def update_count_company_contact
    puts "test .222222.................................."
    if self.deals_contacts.present? && self.deals_contacts.first.contactable.present? && (cc=self.deals_contacts.first.contactable.class.name == "IndividualContact" ? self.deals_contacts.first.contactable.company_contact : self.deals_contacts.first.contactable).present?
      cc.update_column(:total_open_opportunities, cc.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten.select{|d| (d.is_won == nil || d.is_won == "") && d.is_active}.count)
    end
  end
  ### Export CSV ###
  def self.to_csv
    CSV.generate do |csv|
      csv << ["Opportunity", "Stage", "Created On", "Created By", "priority", "Amount", "Active", "Visibility", "Next Action", "Contact Email", "Contact Name"] ## Header values of CSV
      all.each do |lead|
        csv << [lead.title, 
                lead.deal_status_name,
                lead.created_at,
                lead.initiator_name,
                lead.priority_type.present? ? lead.priority_type.name : "NA",
                lead.amount,
                lead.is_active ? "Yes" : "No",
                lead.is_public? ? "Public" : "Everyone",
                lead.last_task.present? ? lead.last_task.name  : "No-Action",
                lead.contacts_email,
                lead.contacts_name ] ##Row values of CSV
      end
    end
  end


  def get_lead_with_priority
  {
    :id => id,
    :deal_name => title,
    :priority => self.priority_type.present? ? self.priority_type.name : "",
    :contact_name => self.deals_contacts.present? ? ((con = self.deals_contacts.first.contactable).present? ? con.name : "") : ""
  }
  end
  
  # Decrypted Deal ID #
  def self.to_decrypt_key encrypted_key
    key = EncryptedId.decrypt(Deal.first.class.encrypted_id_key, encrypted_key)
    key
  end


  def set_tag_owner

    #if self.tag_list_changed?

    unless self.move_deal
        # Set the owner of some tags based on the current tag_list
        set_owner_tag_list_on(self.organization, :tags, self.tag_list)
        # Clear the list so we don't get duplicate taggings
        self.tag_list = nil
    end
 end
  
  def all_tags
    tags.map(&:name).join(", ") 
  end
  
  def create_deal_status_activity
    DealMove.create(:organization => self.organization, :deal_id => self.id, :deal_status_id => self.deal_status_id, :user => User.current)
  end
  def create_won_lost_activity
    #DealTransaction.create({:organization_id => self.organization_id, :deal_id => self.id, :deal_status_id => self.deal_status.id, :user_id => User.current.present? ? User.current.id : self.organization.users.where("admin_type=?",1).first.id})
    if self.is_won.to_s.present?
      status = self.is_won ? "Won" : "Lost"
      Activity.create(:organization_id => self.organization_id,  :activity_user_id => User.current.id,:activity_type=> "DealClosed", :activity_id => self.id, :activity_status => "DealClosed",:activity_desc=>status,:activity_date => self.updated_at, :is_public => (self.is_public.nil? ||  self.is_public.blank?) ? false : self.is_public, :source_id => self.id,:source_type=>self.class.name)
    end
    #Insert into deal transaction with display false
    won_stage = self.organization.deal_statuses.where("lower(name)=?","won").first
    if won_stage.present?
      puts "--------------- won stage"
      DealTransaction.create({:organization_id => self.organization_id, :deal_id => self.id, :deal_status_id => won_stage.id , :user => User.current, :is_activity_display => false, :assigned_to => self.assigned_to.present? ? self.assigned_to : User.current.id})
    end
  end
  def update_stage_move_date
    begin
      if User.current.present? && User.current.organization_id == self.organization_id
        self.update_column :stage_move_date, Time.now
        DealTransaction.create({:organization_id => self.organization_id, :deal_id => self.id, :deal_status_id => self.deal_status.id, :user => User.current, :assigned_to => self.assigned_to.present? ? self.assigned_to : User.current.id})
        #if self.deal_status_id == self.organization.won_deal_status().id
        if self.deal_status_id == self.deal_status_id
           ids = []
           self.deals_contacts.map { |contact| 
                if  contact.contactable.is_individual?
                    ids << contact.contactable.id
                end
            }
            if ids.present?
               IndividualContact.where(id: ids.uniq).update_all(is_customer: true)
            end
        end
      end
    rescue
    end
  end
  
  # def save_activity_after_won_lost
  #   Activity.create(:organization_id => self.organization_id,  :activity_user_id => User.current.id,:activity_type=> "DealTransaction", :activity_id => self.id, :activity_status => "Move",:activity_desc=>self.deal.title,:activity_date => self.updated_at, :is_public => (self.deal.is_public.nil? ||  self.deal.is_public.blank?) ? false : self.deal.is_public, :source_id => self.deal.id,:source_type=>self.deal.class.name)
  # end

  def run_in_background
    InsertOpportunity.perform_async("#{self.id}")    
  end
  
  def update_amount
   @user = User.find self.assigned_to
   if @user.goals.present?
     @user.goals.each do |gl|
       if gl.goal_type == 'value of deals'
         @ugoal = UserGoal.where("user_id =? and goal_id =? and deal_id=?",@user.id,gl.id,self.id).first
         @ugoal.update_attribute(:amount,self.amount) if @ugoal.present?
       end
       if gl.goal_type == 'value of deals won'
         @ugoal = UserGoal.where("user_id =? and goal_id =? and deal_id=?",@user.id,gl.id,self.id).first
         @ugoal.update_attribute(:amount,self.amount) if @ugoal.present?
       end
     end
   end
   
  end
  
  
  def reassign_actvity    
     self.update_column :last_activity_date, Time.zone.now
     Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.assigned_to,:activity_type=> self.class.name, :activity_id => self.id, :activity_status => "Re-assign",:activity_desc=>self.title,:activity_date => self.last_activity_date, :is_public => (self.is_public.nil? ||  self.is_public.blank?) ? false : self.is_public, :source_id => self.id,:activity_by => User.current.id,:source_type=>self.class.name)
     self.update_column(:is_remote, false) unless self.assigned_to.present?
  end
  
  def insert_deal_activity
   if User.current.present? && self.deals_contacts.present?
     de_a = Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.assigned_to,:activity_type=> "Deal", :activity_id => self.id, :activity_status => "Assign",:activity_desc=>self.title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.id,:activity_by => User.current.id,:source_type => self.class.name)
     de_c = Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.initiated_by,:activity_type=> "Deal", :activity_id => self.id, :activity_status => "Create",:activity_desc=>self.title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.id,:source_type => self.class.name)
      if self.deals_contacts.present?
         if(self.deals_contacts.last.contactable_type == "IndividualContact")
          con_type = "IndividualContact"
         else
          con_type = "CompanyContact"
         end
      else
        con_type = nil
      end
     ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> de_c.id,:contactable_type=>con_type,:contactable_id=> self.deals_contacts.last.contactable_id)
     ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> de_a.id,:contactable_type=>con_type,:contactable_id=> self.deals_contacts.last.contactable_id)
     self.update_column :last_activity_date,  de_a.activity_date
    end
  end

  #Update deal activity#
  def create_activity
    org_id = self.organization_id if self.organization_id
    activity_type = self.class.name
    activity_id = self.id
    activity_user_id = self.initiated_by ? self.initiated_by : ""
    activity_date = self.created_at
    activity_desc = self.title
    activity_status = "Update"
    a1=Activity.create(:organization_id => org_id, :activity_user_id => activity_user_id, :activity_type => activity_type, :activity_id => activity_id, :activity_status => activity_status, :activity_desc => activity_desc, :activity_date => activity_date, :is_public => true, :source_id => activity_id,:source_type => self.class.name)
    ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> a1.id,:contactable_type=>self.deals_contacts.last.contactable.class.name,:contactable_id=> self.deals_contacts.last.contactable_id)

  end
  ##After create/update the deal country id will be updated as per the first contact information country
  def update_country_id  
    self.update_column :last_activity_date, Time.zone.now
    
    puts "---------------------End ---- updaing countryid---------------"
    unless self.move_deal
      puts "------------------contact info changed"
      if self.deals_contacts.first
        # if (contact_infos=self.deals_contacts.first).present? && contact_infos.contactable.present? &&  (address_info=contact_infos.contactable.address).present?
        #   self.update_column(:country_id, address_info.country_id)
        # end  
        #d = self
        name = (self.deals_contacts.first.contactable.present? ? self.deals_contacts.first.contactable.full_name : "")
        id = (self.deals_contacts.first.present? ? self.deals_contacts.first.contactable_id : "")
        type = ((deal_contactable=self.deals_contacts.first.contactable).present? && deal_contactable.is_company? ? "company_contact" : "individual_contact")
        phone = (self.deals_contacts.first.contactable.present? && self.deals_contacts.first.contactable.phones.first.present? ? self.deals_contacts.first.contactable.phones.first.phone_no : "")
        email = (self.deals_contacts.first.contactable.present? ? self.deals_contacts.first.contactable.email : "")
        comp_desg = (self.deals_contacts.present? &&  self.deals_contacts.first.contactable.present? && self.deals_contacts.first.contactable.is_company? ? "" : self.collect_company_designaion)
        
        loc= (self.deals_contacts.first.contactable.present? && !self.deals_contacts.first.contactable.address.nil? ? self.deals_contacts.first.contactable.address.city : '')
        
        @s = {"name"=>name,"id"=>id,"type"=> type,"phone"=>phone,"email"=>email,"comp_desg"=>comp_desg,"loc"=>loc}
        #self.contact_info = 
        self.update_column(:contact_info,@s.to_json)
      end
    end
  end
  
  def send_email
    puts "---------------------------------------sending mail from model ---------------"
    self.update_column :last_activity_date, Time.zone.now
    if assigned_user.present? && assigned_user.email
    email = assigned_user.email
    name = assigned_user.full_name
    title = self.title
    deal_id = self.id
  #if (assigned_user.email_notification.nil?) || (assigned_user.email_notification && assigned_user.email_notification.deal_assign == true && assigned_user.email_notification.donot_send == false)
    #Notification.send_deal_info(assigned_user, initiator.full_name, self ).deliver 
    SendEmailNotificationDeal.perform_async(email,name,initiator.full_name,title,deal_id)
  #end
  
    deal_is_opportunity = check_deal_is_opportunity(self.id)
    deal_is_opportunity.call()
  
  end
  end
  #mapping do
   # indexes :image_url
    #indexes :class_name
    #indexes :initiator_name
    #indexes :assigned_user_name
    #indexes :contacts_name
    #indexes :contacts_email
    #indexes :contacts_phone_no
  #end
  
  def to_indexed_json
    to_json( 
      #:only   => [ :id, :name, :normalized_name, :url ],
     :methods   => [:image_url, :initiator_name, :assigned_user_name, :contacts_name, :contacts_email, :contacts_phone_no]
    )
  end
  
  def is_admin_created?
   self.initiator.is_admin? if self.initiator.present?
  end
  
  def image_url
    #if initiator.present? && initiator.image.present?
    #  initiator.image.image.url(:icon)
    #else
    #  "/assets/no_user.png"
    #end
    "#{ENV['cloudfront']}/assets/deal_small.png"
  end
  
  def initiator_name
    initiator.present? ? initiator.full_name : ""
  end
  
  def assigned_user_name
    assigned_user.present? ? assigned_user.full_name : "Not Available"
  end
  
  def contacts_name  
      deals_contacts.map {|a| a.contactable.present? ? a.contactable.full_name : "Not Available"}.join(",")
  end
  
  def contacts_email  
      deals_contacts.map {|a| a.contactable.present? ? (a.contactable.email.present? ? a.contactable.email : "Not Available") : "Not Available"}.join(",")
  end
  
  def contacts_phone_no
      deals_contacts.map {|a| a.contactable.present? ? (a.contactable.phones.first.present? ? a.contactable.phones.first.phone_no : "Not Available") : "Not Available"}.join(",")
  end
  
  def created_by
    initiated_by
  end
  
  def priority_id
    priority_type_id
  end
  
  def deal_status_name
    status=""
    if self.deal_status.present? && !self.is_won.to_s.present?
      status=self.deal_status.name
      status = "New Deal" if self.deal_status.name == "Deal"
    else
      if self.deal_status.present? && self.is_won.to_s.present?
        status = self.is_won ? "Won" : "Lost"
      end
    end
    unless status.present?
      deal_status = self.organization.deal_statuses.where("lower(name) NOT IN (?)", ['won', 'lost']).first
      if deal_status.present?
        self.update_column :deal_status_id, deal_status.id
        status = deal_status.name
      end
    end
    status
  end
  def compdesignation
    self.contact_info.nil? ? "" : self.contact_info['comp_desg']
  end
  
  def contact_name
    self.contact_info.nil? ? "" : self.contact_info['name']
  end
  
  def contact_email
    self.contact_info.nil? ? "" : self.contact_info['email']
  end
  
  def contact_phone
    self.contact_info.nil? ? "" : self.contact_info['phone']
  end
  
  def contact_type
    self.contact_info.nil? ? "" : self.contact_info['type']
  end
  
  def contacts_id
    self.contact_info.nil? ? "" : self.contact_info['id']
  end
  
  def contact_location
    self.contact_info.nil? ? "" : self.contact_info['loc']
  end
  
  def deal_duration
    self.duration.split(",")[0] if self.duration
  end
  
  def deal_duration_type
    self.duration.split(",")[1] if self.duration
  end
  
  def contact_loc
    self.contact_info.nil? ? "" : self.contact_info['loc']
  end
  #for leader dashboard
  def self.find_avg_deal_close_ratio_status_won user_id, org_id, start_date, end_date
    ratio=0
    total_days=0
    user=User.find_by_id user_id
    if(won_deals = user.deals.where("(created_at >= ? AND created_at <= ?) AND is_won =? AND closed_date IS NOT NULL",start_date,end_date,true)).present?
      won_deals.each do |deal|
        total_days += (deal.closed_date.to_date-deal.created_at.to_date).to_i
      end
      ratio = total_days/won_deals.count
    end
    return ratio
    # ratio = 0
    # t = ActiveRecord::Base.connection.execute("select sum(datediff(deal_moves.created_at,deals.created_at)+1)/count(*) as monthly_avg from deals inner join deal_moves on deals.id = deal_moves.deal_id where deal_moves.created_at between '#{start_date}' and '#{end_date}' and deal_moves.deal_status_id in (select id from deal_statuses where organization_id = #{org_id} and original_id in (4)) and (deals.assigned_to = #{user_id})")
    # t.each do |row|
    #   ratio = row[0].to_f
    # end
    # return ratio
  end
  
  def self.find_avg_deal_ratio_status_won user_id, org_id, start_date, end_date
    ratio = 0
    t = ActiveRecord::Base.connection.execute("select sum(datediff(deal_moves.created_at,deals.created_at)+1)/count(*) as monthly_avg, min(datediff(deal_moves.created_at,deals.created_at)+1) as min_avg, max(datediff(deal_moves.created_at,deals.created_at)+1) as max_avg from deals inner join deal_moves on deals.id = deal_moves.deal_id where deals.created_at between '#{start_date}' and '#{end_date}' and deal_moves.deal_status_id in (select id from deal_statuses where organization_id = #{org_id} and original_id in (4)) and (deals.assigned_to = #{user_id})")
     result = []
     t.each do |row|
      result << row[0].to_f
      result << row[1]
      result << row[2]
    end
    return result
  end
  def associated_users
    ids=[]
    ids << self.assigned_to
    ids << self.created_by
    users_involved = self.tasks.map{|t|t.user if self.assigned_user != t.user}.compact.uniq
    users_involved.each do |user|
      ids << user.id
    end
    ids
  end

  def collect_company_designaion
   #.company_contact.present? && @contact.company_contact.name.present?
   if self.deals_contacts.first.contactable && self.deals_contacts.first.contactable.is_individual?
     if (self.deals_contacts.first.contactable.company_contact.present?) && (self.deals_contacts.first.contactable.company_contact.name.present?)
         designation = self.deals_contacts.first.contactable.position 
         company_name = self.deals_contacts.first.contactable.company_contact.name       
         data=""
         if designation.present?
          data += designation
         end
         if company_name.present?
           if data != ""
            data += ", "+company_name
           else
              data += company_name
           end
         end
         data
     end
   end
   
  
  end
  
  def self.active_multi_filter(params)
   
    query=""
    prio=false
    label_type=false
    puts "============================================ 2"
    if params[:label_type].present?
      label_type=true
      query += "`deal_labels`.`user_label_id`=#{params[:label_type]}"
    end
    
    if params[:cre_by] == true || params[:cre_by] == "true"
      if params[:cre_by_val].present? && (cre=params[:cre_by_val].split('|')).present? && (cre_ids=cre.join(','))
        query += "`deals`.`initiated_by` IN (#{cre_ids})"
      end
#    params[:cre_by].present? || params[:cre_by_val].present? || params[:asg_by].present? || params[:asg_by_val].present? || params[:loc].present? || params[:loc_val].present? || params[:priority].present? || params[:priority_val].present?
    end
    if params[:asg_by] == true || params[:asg_by] == "true"
      query += " and "if query.present?
      if params[:asg_by_val].present? && (asg=params[:asg_by_val].split('|')).present?
        if asg[0] == 'unassigned'
          query += "`deals`.`assigned_to` IS NULL"
        else
          asg_ids = asg.join(',')
          query += "`deals`.`assigned_to` IN (#{asg_ids})"
        end
      end
    end
    if params[:loc] == true || params[:loc] == "true"
      query += " and "if query.present?
      if params[:loc_val].present? && (con=params[:loc_val].split('|')).present? && (coun_ids=con.join(','))
        query += "`deals`.`country_id` IN (#{coun_ids})"
      end
    end
    if params[:priority] == true || params[:priority] == "true"
      query += " and "if query.present?
      if params[:priority_val].present? && (prio=params[:priority_val].split('|')).present? && (prio_ids=prio.join(','))
        query += "`deals`.`priority_type_id` IN (#{prio_ids})"
      end
      prio = true
    end
    if params[:next] == true || params[:next] == "true"
      query += " and "if query.present?      
      #query1 += "tasks.task_type_id =#{params[:next_val]} and tasks.is_completed = 0"
      if params[:next_val].present? && (nex=params[:next_val].split('|')).present? && (next_ids=nex.join(','))
        query += "`deals`.`latest_task_type_id` IN (#{next_ids})"
      end
      nex=true
    end
    
    if params[:is_opportunity] == "true"
      query += " and "if query.present?      
      query += "`deals`.`is_opportunity`=true"
    end
    puts "============================================ 1"
    if params[:daterange] == "true"
      query += " and "if query.present?
      if(params[:dt_range] == "This Quarter" || params[:dt_range] == "Last Quarter" ) 
        curr_quarter = ((Date.today.month - 1) / 3) + 1
        #curr_quarter =  get_month_quarter Date.today
        if params[:dt_range] == "This Quarter"
          current_quarter = curr_quarter
        else
          current_quarter = curr_quarter - 1
        end
        if(current_quarter == 1)
          startdate = DateTime.new(Time.zone.now.year,1,1)
          enddate = DateTime.new(Time.zone.now.year,3,31)
        elsif(current_quarter == 2)
          startdate = DateTime.new(Time.zone.now.year,4,1)
          enddate = DateTime.new(Time.zone.now.year,6,30)
        elsif(current_quarter == 3)
          startdate = DateTime.new(Time.zone.now.year,7,1)
          enddate = DateTime.new(Time.zone.now.year,9,30)
        elsif(current_quarter == 4)
          startdate = DateTime.new(Time.zone.now.year,10,1)
          enddate = DateTime.new(Time.zone.now.year,12,31)
        elsif(current_quarter == 0)
          startdate = DateTime.new(Time.zone.now.year - 1,10,1)
          enddate = DateTime.new(Time.zone.now.year - 1,12,31)
        end
      elsif params[:dt_range] == "This Week"
        startdate = 0.week.ago.beginning_of_week
        enddate = 0.week.ago.end_of_week
        
      elsif params[:dt_range] == "Last Week"
        startdate = 1.week.ago.beginning_of_week
        enddate = 1.week.ago.end_of_week
      
      elsif params[:dt_range] == "This Month"
        startdate = 0.month.ago.beginning_of_month
        enddate = 0.month.ago.end_of_month
      elsif params[:dt_range] == "Last Month"
        startdate = 1.month.ago.beginning_of_month
        enddate = 1.month.ago.end_of_month

      elsif params[:dt_range] == "This Year"
          startdate = 0.year.ago.beginning_of_year
          enddate = 0.year.ago.end_of_year
      elsif params[:dt_range] == "Last Year"
          startdate = 1.year.ago.beginning_of_year
          enddate = 1.year.ago.end_of_year
      end
      # if params[:dt_range] == "Past Week"
      #    startdate = 1.week.ago.beginning_of_week.strftime("%Y-%m-%d")
      #    enddate = 1.week.ago.end_of_week.strftime("%Y-%m-%d")
      # elsif params[:dt_range] == "Past Two Weeks"
      #    startdate = 2.week.ago.beginning_of_week.strftime("%Y-%m-%d")
      #    enddate = 1.week.ago.end_of_week.strftime("%Y-%m-%d")
      # elsif params[:dt_range] == "Past Three Weeks"
      #    startdate = 3.week.ago.beginning_of_week.strftime("%Y-%m-%d")
      #    enddate = 1.week.ago.end_of_week.strftime("%Y-%m-%d")
      # elsif params[:dt_range] == "Past Month"
      #    startdate = 1.month.ago.beginning_of_month.strftime("%Y-%m-%d")
      #    enddate = 1.month.ago.end_of_month.strftime("%Y-%m-%d")
      # elsif params[:dt_range] == "Past Year"
      #    startdate = DateTime.new(Time.zone.now.year-1,1,1).strftime("%Y-%m-%d")
      #    enddate = DateTime.new(Time.zone.now.year-1,12,31).strftime("%Y-%m-%d")
      # elsif params[:dt_range] == "3m"
      #    startdate = 3.months.ago.beginning_of_month.strftime("%Y-%m-%d")
      #    enddate = 3.months.ago.end_of_month.strftime("%Y-%m-%d")
      # end      
      query += "`deals`.`created_at` BETWEEN '#{startdate}' AND '#{enddate}'"
    end
    puts "============================================ 12"
    puts "------------------------- date range"
    p params[:dtrange_from]
    p params[:dtrange_to]
     if ((params[:dtrange_from] == true || params[:dtrange_from] == "true") && (params[:dtrange_to] == true || params[:dtrange_to] == "true"))
      query += " and "if query.present?
      frmdate = Date.parse(params[:dt_range_from]).strftime("%Y-%m-%d")
      todate = Date.parse(params[:dt_range_to]).strftime("%Y-%m-%d")
      query += "`deals`.`created_at` BETWEEN '#{frmdate}' AND '#{todate}'"
      puts "+++++++++++++++++++++++++++++++++++++"
      p query
     end

    if params[:last_tch] == "true"
      query += " and "if query.present?
      if params[:last_touch] == "Last Week"
        last_d = (DateTime.now - 7.days).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Two Weeks"
        last_d = (DateTime.now - 14.days).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Three Weeks"
        last_d = (DateTime.now - 21.days).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Month"
        last_d = (DateTime.now - 1.month).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Three Months"
        last_d = (DateTime.now - 3.month).strftime("%Y-%m-%d")
      end
     query += "`deals`.`last_activity_date` < '#{last_d}'"
    end
    if params[:stage] == true || params[:stage] == "true"
      query += " and "if query.present?
      if params[:stage_val].present? && (stage=params[:stage_val].split('|')).present? && (stage_ids=stage.join(','))
        query += "`deals`.`deal_status_id` IN (#{stage_ids}) AND `deals`.`is_won` IS NULL"
        lead_stages = DealStatus.where("id IN (#{stage_ids})")
        if lead_stages.present?
          if lead_stages.where("lower(name)=?", 'lost').present?
            query += " or "if query.present?
            query += "`deals`.`is_won` = #{false}"
          end
          if lead_stages.where("lower(name)=?", 'won').present?
            query += " or "if query.present?
            query += "`deals`.`is_won` = #{true}"
          end
        end
      end
      stage = true
    end
    if params[:user_label] == true || params[:user_label] == "true"
      query += " and "if query.present?
      if params[:user_label_val].present? && (user_label=params[:user_label_val].split('|')).present? && (user_label_ids=user_label.join(','))
        query += "`deals`.`user_label_id` IN (#{user_label_ids})"
      end
      user_label = true
    end
    #if prio
     #joins(:priority_type).where(query).order("last_activity_date desc")
    #else
    # if params[:format].present? && params[:format] == 'pdf' && params[:dtype] == 'my_deals'
    #   cuser =User.find params[:cuser]
    #   query += " and " if query.present?
    #   query += "(`deals`.`assigned_to` = #{cuser.id} or `deals`.`initiated_by` = #{cuser.id} )"
    # end
    if label_type
     joins(:deal_labels).where(query)
    else
     where(query).order("last_activity_date desc")
    end
    #end
  end
  
  def closed_by_name
    user=User.where(id: self.closed_by).first
    user.present? ? user.full_name : ""
  end

    def need_attention?(current_user)
      attention_required = false
    if created_at.in_time_zone(current_user.time_zone) + 24.hours < Time.zone.now
      attention_required = true
      if tasks.present?
        attention_required = false if (tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d")).count == 0)
      elsif attachments.present?
        attention_required = false if (attachments.last.created_at.in_time_zone(current_user.time_zone) + 24.hours > Time.zone.now)
      end
    end
    attention_required
  end
  
  
  def self.avg_time_close_deal user, org_id, start_date, end_date
    ratio = 0    
    unless (user.is_admin? || user.is_super_admin?)
        t = ActiveRecord::Base.connection.execute("select sum(datediff(deal_moves.created_at,deals.created_at)+1)/count(*) as monthly_avg from deals inner join deal_moves on deals.id = deal_moves.deal_id where deal_moves.created_at between ? and ? and deal_moves.deal_status_id in (select id from deal_statuses where organization_id = ? and original_id in (4)) and (deals.assigned_to = ?)", start_date, end_date, org_id, user.id)

     else
        t = ActiveRecord::Base.connection.execute("select sum(datediff(deal_moves.created_at,deals.created_at)+1)/count(*) as monthly_avg from deals inner join deal_moves on deals.id = deal_moves.deal_id where deal_moves.created_at between '#{start_date}' and '#{end_date}' and deal_moves.deal_status_id in (select id from deal_statuses where organization_id = #{org_id} and original_id in (4))")
     end
     t.each do |row|
      ratio = row[0].to_f
    end
    return ratio
  end
  
  def get_color_code char
    if(["a","e","i","m"].include?(char.to_s))
      color = "#F4511E"
    elsif(["c","g","k","o","r"].include?(char.to_s))
      color = "#CCCC65"
    elsif(["d","h","l"].include?(char.to_s))
      color = "#9575CD"
    elsif(["p","s"].include?(char.to_s))
      color = "#FFA726"
    elsif(["t","u","v","w"].include?(char.to_s))
      color = "#4FC3F7"
    elsif(["b","f","j","n","q"].include?(char.to_s))
      color = "#FF8A65"
    elsif(["x","y","z"].include?(char.to_s))
      color = "#A1887F"
    else
      color = "#A1887F"
    end
    return color
  end

  def self.get_last_task_duedate deal
     #task = Task.select("due_date").where("task_type_id=?", deal.latest_task_type_id).first
   task = Task.select("due_date").where("deal_id =? and task_type_id=?",deal.id,deal.latest_task_type_id).not_completed.last

     return (task.due_date.strftime("%a - %b %d, %Y @ %H:%M") if task)
  end

  def send_mailto_assigned_user
    current_user=User.current
    if current_user.present?
      org=current_user.organization
      if current_user.id != self.assigned_to
        begin
          Notification.send_deal_assigned_email_notification(org.users.find(self.assigned_to), self, org.users.find(self.initiated_by)).deliver
        rescue
        end
      end
    end
  end

  #This method will save the deal stages into deal transaction table if deal stage is directly changed to higher stage
  def add_stages_to_transaction
    org_stages = self.organization.deal_statuses.where("name NOT IN (?)", ['Won', 'Lost']).order("original_id")    
    org_stages.each do |stage|
      if stage.id == self.deal_status_id
        break
      else
        stage = self.organization.deal_statuses.where("id=?",stage.id).first
        if stage.present? && stage.name.downcase != "won"
          begin
            DealTransaction.create({:organization_id => self.organization_id, :deal_id => self.id, :deal_status_id => stage.id, :user => User.current, :is_activity_display => false, :assigned_to => self.assigned_to.present? ? self.assigned_to : User.current.id})
          rescue
          end
        end
      end
    end
  end
end

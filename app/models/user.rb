# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  organization_id         :integer
#  email                   :string(255)      default(""), not null
#  first_name              :string(255)
#  last_name               :string(255)
#  role_id                 :integer
#  target                  :integer
#  admin_type              :integer
#  encrypted_password      :string(255)      default("")
#  reset_password_token    :string(255)
#  reset_password_sent_at  :datetime
#  remember_created_at     :datetime
#  sign_in_count           :integer          default(0), not null
#  current_sign_in_at      :datetime
#  last_sign_in_at         :datetime
#  current_sign_in_ip      :string(255)
#  last_sign_in_ip         :string(255)
#  confirmation_token      :string(255)
#  confirmed_at            :datetime
#  confirmation_sent_at    :datetime
#  unconfirmed_email       :string(255)
#  failed_attempts         :integer          default(0), not null
#  unlock_token            :string(255)
#  locked_at               :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  time_zone               :string(255)
#  invitation_token        :string(255)
#  invitation_created_at   :datetime
#  invitation_sent_at      :datetime
#  invitation_accepted_at  :datetime
#  invitation_limit        :integer
#  invited_by_id           :integer
#  invited_by_type         :string(255)
#  is_active               :boolean          default(TRUE)
#  task_date               :datetime
#  digest_mail_date        :string(255)
#  priority_label          :integer          default(0), not null
#  provider                :string(255)
#  uid                     :string(255)
#  token                   :string(255)
#  gmail_related_id        :integer
#  is_blocked              :boolean          default(FALSE)
#  is_disabled             :boolean          default(FALSE)
#  email_setup_at          :datetime
#  smtp_config             :string(255)
#  is_email_bounce         :boolean          default(FALSE)
#  user_designation_id     :integer
#  user_hourly_billable_id :integer
#

require 'rest-client'

class User < ActiveRecord::Base
  # include Humanizer
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable,:database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable#, :confirmable, :omniauthable, :omniauth_providers => [:google_oauth2, :linkedin]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
                  :remember_me,:admin_type, :time_zone, :task_date,
                  :first_name, :last_name, :work_phone, :role_id, :profile_image, :confirmed_at, :confirmation_token, :is_beta_user,:priority_label,:digest_mail_date, :organization_id, :provider, :uid, :token, :is_blocked, :organization_name, :nickname, :is_active, :invitation_token, :invitation_accepted_at, :is_disabled, :is_email_bounce, :smtp_config, :email_setup_at, :disable_google_task_sync, :google_task_sync_display_at, :organization_website, :organization_size, :terms, :user_designation_id, :user_hourly_billable_id
  attr_accessor :nickname, :terms,:area_code,:phone_no
  # attr_accessible :title, :body
  belongs_to :organization
  belongs_to :organization_type
  belongs_to :role
  has_one :smtp_configuration
  has_one :user_preference, :dependent => :destroy
  has_one :deal_setting, :dependent => :destroy
  has_one :user_role, :dependent => :destroy
  has_one :phone, :as => :phoneble, :dependent => :destroy
  has_one :address, :as => :addressable,:class_name=>"Address", :dependent => :destroy
  has_one :image, :as => :imagable, :dependent => :destroy
  has_one :email_notification, :dependent => :destroy
  has_one :attention_deal, :dependent => :destroy
  has_one  :widget, :dependent => :destroy
  has_many :deals, :class_name=>"Deal", :dependent => :nullify,:foreign_key=>"assigned_to"
  has_many :user_labels,:class_name=>"UserLabel", :dependent => :destroy
  has_many :attachments, :class_name=>"Note", :dependent => :nullify,:foreign_key=>"created_by"
  has_many :activities, :dependent => :destroy,:foreign_key=>"activity_user_id"
  has_many :user_plugins
  has_many :in_app_notifications
  has_many :plugins, :through => :user_plugins
  has_one :email_account
  has_one :office_mail
  belongs_to :user_designation
  has_many :user_subscriptions
  has_many :feedbacks
  has_many :goals, :dependent => :destroy
  has_many :user_goals
  has_many :user_hourly_billables, :dependent => :destroy
  belongs_to :user_hourly_billable

  has_many :project_jobs,:foreign_key=>"assigned_to"
  has_many :projects, :foreign_key=>"project_manager_id"
  attr_accessor :organization_name, :organization_type, :name,:organization_website,:organization_size, :work_phone, :profile_image, :is_beta_user
  after_save :save_other_information
  after_create :create_default_data
  scope :by_active, lambda{where("is_active = ? AND is_disabled = ?", true, false)}
  scope :by_not_active, lambda{where("is_active = ? AND is_disabled = ?", false, true)}
  scope :by_enabled, lambda{where("is_disabled = ?", false)}
  #require_human_on :create
  scope :by_inactive, lambda{where("is_active = ?", false)}
  scope :by_month_year, lambda { |month, year| where('extract(month from created_at) = ? AND extract(year from created_at) = ?', month, year) }
  accepts_nested_attributes_for :address
  
  def self.current
    Thread.current[:user]
  end
  def self.current=(user)
    Thread.current[:user] = user
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil,request_ip)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      user.token = access_token.credentials.token
      user.save!
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        registered_user.provider = access_token.provider
        registered_user.uid = access_token.uid
        registered_user.token = access_token.credentials.token
        registered_user.save!
        return registered_user
      else
        user = User.create(first_name: data["first_name"],
          last_name: data["last_name"],
          provider:access_token.provider,
          email: data["email"],
          uid: access_token.uid ,
          token: access_token.credentials.token,
          password: Devise.friendly_token[0,20],
		      admin_type: 1,
		      confirmation_token: nil,
          confirmed_at: Time.now,		  
        )
        Notification.mail_notification_for_social_signup_user(user).deliver
        # begin
        #   RestClient.post 'http://blog.wakeupsales.com/auto_subscription_blog.php', {email: user.email, domain: 'cloud'}
        # rescue
        # end
        begin
          result = Geocoder.search(request_ip)
          Notification.mail_notification_to_support(user, result).deliver
        rescue            
        end
        if User.current.present? && User.current.email != data["email"]
          User.current.update_column :gmail_related_id, user.id
        end
        return user
      end
   end
end


def self.connect_to_linkedin(auth, signed_in_resource=nil,request_ip)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(first_name:auth.info.first_name,
                            last_name:auth.info.last_name,
                            provider:auth.provider,
                            uid:auth.uid,
                            email:auth.info.email,
                            password:Devise.friendly_token[0,20],
							              admin_type: 1,
		                        confirmation_token: nil,
                            confirmed_at: Time.now,
                          )
        Notification.mail_notification_for_social_signup_user(user).deliver
        # begin
        #   RestClient.post 'http://blog.wakeupsales.com/auto_subscription_blog.php', {email: user.email, domain: 'cloud'}
        # rescue
        # end
        begin
          result = Geocoder.search(request_ip)
          Notification.mail_notification_to_support(user, result).deliver
        rescue            
        end
      end
      return user
    end
  end   
  

  def create_default_data
    # p 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY'
    # p 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY'
    # p 'User Created'
    # p 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY'
    # p 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY'
     Widget.create :organization_id => self.organization.present? ? self.organization.id : nil, :user => self
     UserPreference.create :organization_id => self.organization.present? ? self.organization.id : nil, :user => self
     
     # set organization id as per organization id of current user
     @deal_status = DealStatus.where(:organization_id => 1)
     @deal_status.each do |org_id|
      org_id.organization_id = self.organization_id
     end
    if self.organization.present?
      DealSetting.create(:organization=>self.organization, :user=> self, :tabs=> self.organization.deal_statuses.where('LOWER(name) in (?)', %w(incoming qualified)).map(&:id).join(','))
    end
  end
  # def name
    # if first_name.present? && last_name.present?
      # first_name+" "+last_name
    # else
      # first_name
    # end
  # end
  def invited_by_wus_user
    user = self.organization.users.where(self.invited_by_id).first
    user.full_name.present? ? user.full_name : user.email
  end

  def self.current
    Thread.current[:user]
  end
  
  def self.current=(user)
    Thread.current[:user] = user
  end
  
  def all_deals
    ## disabled public deals view by normal user
    #return Deal.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",self.id,self.id,self.organization.id).order("deals.created_at DESC")  
    if(self.is_admin? or self.is_super_admin?)
      return Deal.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",self.id,self.id,self.organization.id).order("deals.created_at DESC")  
    else
      return Deal.where("(assigned_to = ? or initiated_by= ?) and ( deals.organization_id = ?)",self.id,self.id,self.organization.id).order("deals.created_at DESC")   
    end
  end
  
  def my_deals
    return Deal.where("(assigned_to = ? or initiated_by= ?) and deals.organization_id = ?",self.id,self.id,self.organization.id).order("deals.created_at DESC")    
  end
 
  def my_created_deals
    return Deal.where("initiated_by= ? and deals.organization_id = ?",self.id,self.organization.id).order("deals.created_at DESC")    
  end
  
  #Using for last deal close for non-admin user
  def all_deals_dashboard
    #return Deal.where("assigned_to = ? or initiated_by= ?",self.id,self.id)
    return Deal.where("deals.assigned_to = ? or deals.initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",self.id,self.id,self.organization.id)    
  end
  
  def my_deals_dashboard
    #return Deal.where("assigned_to = ? or initiated_by= ?",self.id,self.id)
    return Deal.where("(deals.assigned_to = ? or deals.initiated_by= ?) and deals.organization_id = ?",self.id,self.id,self.organization.id)    
  end 
  
  def all_assigned_or_created_deals
    #return Deal.where("assigned_to = ? or initiated_by= ?",self.id,self.id)
    return Deal.where("(deals.assigned_to = ? or deals.initiated_by= ?) and deals.organization_id = ?",self.id,self.id, self.organization_id).order("deals.created_at DESC")    
  end
  
  def all_assigned_deal
    return Deal.where("deals.assigned_to = ? and deals.organization_id = ? ",self.id, self.organization_id)
  end
  
  def all_tasks
    return Task.where("(tasks.created_by = ? or tasks.assigned_to = ?)  and organization_id = ?",self.id,self.id, self.organization_id)
  end
  
  
  def all_tasks_assigned
    return Task.where("tasks.assigned_to = ?  and tasks.organization_id = ?",self.id, self.organization_id)
  end
  
  
  def save_other_information
    if (self.image.nil?) && self.profile_image.present?
      Image.create(:organization => self.organization,:image=> self.profile_image, :imagable=> self)
    elsif self.image.present? && self.profile_image.present?
      self.image.update_attributes(:image=> self.profile_image)
    end
    if !(self.phone.present?) && self.work_phone.present?
      Phone.create(:organization => self.organization,:phone_no=> self.work_phone, :phoneble=> self)
    elsif self.phone.present? && self.work_phone.present?
      self.phone.update_attributes(:phone_no=> self.work_phone)
    end
    
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  # def name
    # return first_name + (!last_name.nil? && !last_name.blank? ? " " + last_name : "")
  # end
  def is_super_admin?
    if admin_type == 1
      return true
    else
      return false
    end
  end
  def is_admin?
    admin_type == 2 or admin_type ==1
  end
  
  def is_siteadmin?
    admin_type == 0
  end
  
  def is_user?
    admin_type == 3
  end

  def is_client?
    admin_type == 4
  end  

  def is_lead_owner? deal_id
    begin
      deal = Deal.find_by_id deal_id
      if deal.present?
        if deal.deals_contacts.first.contactable_type == "IndividualContact" && deal.deals_contacts.first.contactable.owner_id == self.id
          return true
        else
          return false
        end
      end
    rescue => e
      return false
    end
  end  
  
  def get_user_color_code char
    if(["a","e","i","m"].include?(char.to_s))
      color = "#FF00FF"
    elsif(["c","g","k","o","r"].include?(char.to_s))
      color = "#008000"
    elsif(["d","h","l"].include?(char.to_s))
      color = "#0000FF"
    elsif(["p","s"].include?(char.to_s))
      color = "#800080"
    elsif(["t","u","v","w"].include?(char.to_s))
      color = "#ff5733"
    elsif(["b","f","j","n","q"].include?(char.to_s))
      color = "#00CA94"
    elsif(["x","y","z"].include?(char.to_s))
      color = "#5b2c6f"
    end
    return color
  end

  

  def after_password_reset; end

  protected
  # def confirmation_required?
  #   # puts "----------------- confirmation_required? ------------------"
  #   # p self.email
  #   # begin
  #   #   EmailVerifier.check(self.email)# ? true : false
  #   # rescue
  #     false
  #   # end
  # end
  
  
end

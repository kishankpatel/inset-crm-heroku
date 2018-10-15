# == Schema Information
#
# Table name: individual_contacts
#
#  id                  :integer          not null, primary key
#  organization_id     :integer
#  first_name          :string(255)
#  last_name           :string(255)
#  email               :string(255)
#  position            :string(255)
#  messanger_type      :string(255)
#  messanger_id        :string(255)
#  linkedin_url        :string(255)
#  facebook_url        :string(255)
#  twitter_url         :string(255)
#  company_contact_id  :integer
#  created_by          :integer
#  is_public           :boolean          default(TRUE), not null
#  is_active           :boolean          default(TRUE), not null
#  contact_ref_id      :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  time_zone           :string(255)
#  is_customer         :boolean          default(FALSE), not null
#  subscribe_blog_mail :boolean          default(TRUE), not null
#  subscribe_blog_date :datetime
#  website             :string(255)
#  city                :string(255)
#  state               :string(255)
#  country_id          :integer
#  company_name        :string(255)
#  work_phone          :string(255)
#  description         :text
#  is_csv              :boolean          default(FALSE)
#  is_archive          :boolean          default(FALSE)
#  is_accessible       :boolean          default(TRUE)
#  owner_id            :integer
#

class IndividualContact < ActiveRecord::Base
  include EncryptedId
  belongs_to :organization
   attr_accessible :first_name, :last_name, :position,
                   :organization, :email, :country, :country_id, :created_by, :is_public, :organization_id,
                   :extension, :contact_image, :company_contact_id,:note,:file_description,:attachment,
                   :city, :state, :zip_code,:mobile_number,:contact_image, :street, :website, :company_name,
                   :name, :work_phone, :facebook_url, :twitter_url, :linkedin_url,
                   :messanger_type, :messanger_id, :time_zone, :subscribe_blog_mail, :subscribe_blog_date, :description, :contact_id, :is_csv, :opportunity, :owner_id
#   accepts_nested_attributes_for :company_contact, :reject_if => lambda { |a| a[:company_name].blank? && a[:company_strength_id].blank? }, :allow_destroy => true

  attr_accessor  :work_phone,:mobile_number, :extension, :note,:file_description,:attachment,
                :zip_code,:mobile_number,:contact_image, :street, :name
  belongs_to :company_strength
  #has_many :deals, :dependent => :nullify, :primary_key => "contact_ref_id", :foreign_key => "contact_id"
  has_one :address, :as => :addressable,:class_name=>"Address", :dependent => :destroy
  has_many :phones, :as => :phoneble , :dependent => :destroy
  has_many :work_phones, :as => :phoneble,:class_name=>"Phone", :conditions => { :phone_type => 'work'}
  
  has_many :deals_contacts, :as => :contactable,:class_name=>"DealsContact", :dependent => :destroy
  has_one :image,:class_name=>"Image",:as=>:imagable, :dependent => :destroy
  has_many :attachments,:class_name=>"Note",:as=>:notable, :dependent => :destroy
  has_many :deals, :dependent => :nullify
  has_many :tasks, :as=> :taskable, :dependent => :destroy
  belongs_to :initiator,:class_name=>"User",:foreign_key=>"created_by"
  belongs_to :owner,:class_name=>"User",:foreign_key=>"owner_id"
  belongs_to :company, :class_name => "CompanyContact"
  belongs_to :company_contact
  has_many :secondary_companies, :dependent => :destroy
  belongs_to :country
  has_one :contact_opportunity, :dependent => :destroy
  has_many :invoices, :foreign_key=>"contact_id", :dependent => :nullify
  has_many :projects, :dependent => :nullify

  #has_many :activities, :class_name=>"Activity", :dependent => :destroy,:foreign_key=>"source_id"
  has_many  :activities_contacts,:as => :contactable, :dependent => :destroy,:class_name=>"ActivitiesContact"
  has_many :mail_letters, :as => :mailable
  has_many :project_jobs, :as => :contactable
  validates :email, :uniqueness =>  {scope: :organization_id, message: "has already been taken!"}, :allow_blank => false
  
  default_scope where(:is_accessible => true, :is_archive => false)
  scope :by_not_archived, lambda{where("is_archive = ? ", false)}  
  scope :by_contact_type, lambda{|type| where("contact_type = ? ", type)}  
  scope :by_organization_id, lambda{|org_id| where("organization_id = ? ", org_id)}  
  ## disabled public deals view by normal user
  #scope :by_visibilty, lambda{|org_id,user_id| where("organization_id = ? and (is_public = true or (is_public = false and created_by=?))", org_id,user_id) }     
  scope :by_visibilty, lambda{|org_id,user_id| where("organization_id = ? and (created_by=?)", org_id,user_id) }       
  # scope :search_by, lambda{|data| where("first_name REGEXP ? or last_name REGEXP ? or email REGEXP ?", data, data,data)}
  scope :search_by, lambda{|data| where('first_name LIKE ? OR last_name LIKE ? OR email LIKE ?', data.split(" ").present? ? data.split(" ").first+"%" : data+"%", data.split(" ").present? ? data.split(" ").last+"%" : data+"%", data+"%").order("first_name asc")} 

  scope :by_first_letter,   lambda{|type| where("first_name like ?", type + '%')}  
  scope :by_first_letter_name,   lambda{|type| where("first_name like ?", type + '%')}  
  scope :by_alpha_firstname,   lambda{where("first_name REGEXP '^[^A-Za-z]' " )}  
  scope :by_alpha_name,   lambda{ where("first_name REGEXP '^[^A-Za-z]' ")}  
  scope :is_customer, lambda {where("is_customer = ?", true)}  
  encrypted_id key: '7b82baa4841b8251f9ed3688b11d3ab9d5ca'
  
   after_save :save_other_info
   #after_update :save_other_info
   before_create :set_messanger
   after_save :save_to_phone
   after_update :create_activity
      
   def set_messanger
      self.messanger_type = "Skype"
   end   

  # Decrypted Individual Contact ID #
  def self.to_decrypt_key encrypted_key
    key = EncryptedId.decrypt(IndividualContact.first.class.encrypted_id_key, encrypted_key)
    key
  end

  def save_to_phone
    ##save phone numbers to phone
     work_phone_obj = self.phones.by_phone_type "work"
     mobile_phone_obj = self.phones.by_phone_type "mobile"
     work_phone = work_phone_obj.first.phone_no if work_phone_obj.present?
     mobile_number = mobile_phone_obj.first.phone_no if mobile_phone_obj.present?
     if work_phone_obj.present? #&& work_phone.present?
       work_phone_obj.first.update_attributes( phone_no: work_phone, extension: extension)
     else
       Phone.create(organization_id: organization_id, phone_no: work_phone, extension: extension, phone_type: "work", phoneble: self)
     end
     if mobile_phone_obj.present? #&& mobile_number.present?
       mobile_phone_obj.first.update_attributes( phone_no: mobile_number, extension: extension)
     else
       Phone.create(organization_id: organization_id, phone_no: mobile_number, extension: extension, phone_type: "mobile", phoneble: self)
     end
  end
   
   def save_other_info
    ##save address information for contact
     unless self.address.present?
      address = Address.create organization: organization, addressable: self, address: street, country_id: country, state: state, city: city, zipcode: zip_code
     else
      self.address.update_attributes(address: street, country_id: country, state: state, city: city, zipcode: zip_code)
     end
   ##save phone numbers to phone
     work_phone_obj = self.phones.by_phone_type "work"
     mobile_phone_obj = self.phones.by_phone_type "mobile"
     if work_phone_obj.present? #&& work_phone.present?
       work_phone_obj.first.update_attributes( phone_no: work_phone, extension: extension)
     else
       Phone.create(organization_id: organization_id, phone_no: work_phone, extension: extension, phone_type: "work", phoneble: self)
     end
     if mobile_phone_obj.present? #&& mobile_number.present?
       mobile_phone_obj.first.update_attributes( phone_no: mobile_number, extension: extension)
     else
       Phone.create(organization_id: organization_id, phone_no: mobile_number, extension: extension, phone_type: "mobile", phoneble: self)
     end
     
   ##save image to image
     if !self.image.present? && contact_image.present? 
      image = Image.create(organization: organization, image: contact_image, imagable: self)
     elsif self.image.present? && contact_image.present?
      self.image.update_attributes(image: contact_image)
     end
     contact = self
     
     contact.deals_contacts.each do |dc|
       if dc.present? && dc.deal.present?
         deal = dc.deal 
         
         #puts "==========> "
         #p dc.deal.present?
         #p deal
         
         #p deal.deals_contacts.count
         deal_contacts_id = deal.deals_contacts.first.contactable if deal.deals_contacts.present? && deal.deals_contacts.first.contactable.present?
     
         if deal.present? && deal_contacts_id.present? && ( (self.id == deal_contacts_id.id) && (self.class.name == deal_contacts_id.class.name ) )
              d = deal
               name = (d.deals_contacts.first.contactable.present? ? d.deals_contacts.first.contactable.full_name : "")
              id = (d.deals_contacts.first.present? ? d.deals_contacts.first.contactable_id : "")
              type = (d.deals_contacts.first.contactable.is_company? ? "company_contact" : "individual_contact")
              phone = (d.deals_contacts.first.contactable.present? && d.deals_contacts.first.contactable.phones.first.present? ? d.deals_contacts.first.contactable.phones.first.phone_no : "")
              email = (d.deals_contacts.first.contactable.present? ? d.deals_contacts.first.contactable.email : "")
              comp_desg = (d.deals_contacts.present? &&  d.deals_contacts.first.contactable.present? && d.deals_contacts.first.contactable.is_company? ? "" : d.collect_company_designaion)
              
              loc= (d.deals_contacts.first.contactable.present? && !d.deals_contacts.first.contactable.address.nil? ? d.deals_contacts.first.contactable.address.city : '')
              
              @s = d.contact_info = {"name"=>name,"id"=>id,"type"=> type,"phone"=>phone,"email"=>email,"comp_desg"=>comp_desg,"loc"=>loc}
             deal.update_column(:contact_info,@s.to_json)
         end
     
        end
     end
   end
  #Update deal activity#
  def create_activity
    org_id = self.organization_id if self.organization_id
    activity_type = self.class.name
    activity_id = self.id
    activity_user_id = self.created_by
    activity_date = self.created_at
    activity_desc = self.full_name
    activity_status = "Update"
    Activity.create(:organization_id => org_id, :activity_user_id => activity_user_id, :activity_type => activity_type, :activity_id => activity_id, :activity_status => activity_status, :activity_desc => activity_desc, :activity_date => activity_date, :is_public => true, :source_id => activity_id,:source_type=>self.class.name)
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

  def full_name
    if first_name.present? && last_name.present? 
      "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    elsif last_name.present?
      last_name
    end
  end
  def name
    if first_name.present? && last_name.present? 
      "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    elsif last_name.present?
      last_name
    end
  end
  
  ##for dasboard activity 
  def title
    data=""
    if first_name.present? && last_name.present? 
      data="#{first_name} #{last_name}"
    elsif first_name.present?
      data=first_name
    elsif last_name.present?
      data=last_name
    end
    data
  end
    
  def contact_name
    "#{first_name}"
  end
  
  ## Stuffs for elasitic search functionality
    
 # include Tire::Model::Search
  #include Tire::Model::Callbacks
  
  #mapping do
   # indexes :title
    #indexes :email_field #, :analyzer => 'whole_email', :boost => 10
    #indexes :image_url
    #indexes :initiator_name
    #indexes :phone_number
    #indexes :country_name
    #indexes :contact_status
    #indexes :country_id
    #indexes :contacts_name
    #indexes :contacts_email
    #indexes :contacts_phone_no
#    indexes :phones do
#      indexes :phone_number
#    end
  #end
  
#  def to_indexed_json
#    to_json(:methods => [:title, :image_url])
#  end
  def to_indexed_json
    to_json( 
      #:only   => [ :id, :name, :normalized_name, :url ],
       :methods   => [:title,:email_field,:image_url,:initiator_name, :phone_number, :country_name, :country_id, :contact_status, :contacts_name, :contacts_email, :contacts_phone_no ]
    )
  end
  
  def email_field
    (self.email.present? ? self.email : "")
  end
  
  def image_url
   # if self.image.present?
   #   image.image.url(:icon)
   # else
   #   "/assets/no_user.png"
   # end
   "#{ENV['cloudfront']}/assets/no_user.png"
  end
  
  def initiator_name
    initiator.present? ? initiator.full_name : ""
  end
  
  def phone_number
    
    phones.present? ? phones.first.phone_no : ""
  end
  
   def contacts_name  
      full_name.present? ? full_name : ""
  end
  
  def contacts_email  
      email.present? ? email : ""
  end
  
  def contacts_phone_no
      phones.present? ? phones.first.phone_no : ""
  end
  
  
  def country_name
  
    (self.address.present? && self.address.country.present?) ? self.address.country.name : (country.present? ? Country.find(country).name : 1)
  end
  
  def country_id
    (self.address.present? && self.address.country.present?) ? self.address.country.id : country
  end
  
  def is_individual?
    true
  end
  
  def is_company?
    false
  end
  
  def contact_status
    self.is_active? ? true : false
  end

  def contact_status_disabled
    self.is_active? ? 1 : 0
  end

  def get_project_count
    self.projects.count
  end

  def get_type
    cont_type = "Contact"
    if self.projects.count > 0
      return cont_type = "Client"
    elsif self.deals_contacts.present?
      self.deals_contacts.order("id desc").each do |dc|
        if dc.present? && dc.deal.present? && dc.deal.is_active && (dc.deal.is_won.to_s.present? && dc.deal.is_won)
          return cont_type = "Client"
        end
      end
      return cont_type = "Lead"
    else
      cont_type = "Contact"
    end
  end

  def last_task
    task = self.tasks.not_completed.last
   # Task.where("taskable_type =? AND taskable_id=?", "IndividualContact", self.id).not_completed.last
   if task.present?
     task.task_type
   else
     nil
   end
  end
end 

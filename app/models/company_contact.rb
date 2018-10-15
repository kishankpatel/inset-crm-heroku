# == Schema Information
#
# Table name: company_contacts
#
#  id                       :integer          not null, primary key
#  organization_id          :integer
#  name                     :string(255)
#  company_strength_id      :integer
#  email                    :string(255)
#  messanger_type           :string(255)
#  messanger_id             :string(255)
#  website                  :string(255)
#  linkedin_url             :string(255)
#  facebook_url             :string(255)
#  twitter_url              :string(255)
#  created_by               :integer
#  is_public                :boolean          default(TRUE), not null
#  is_active                :boolean          default(TRUE), not null
#  contact_ref_id           :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  time_zone                :string(255)
#  country_id               :integer
#  is_accessible            :boolean          default(TRUE)
#  total_opportunities      :integer          default(0)
#  total_open_opportunities :integer          default(0)
#

class CompanyContact < ActiveRecord::Base
  include EncryptedId
  belongs_to :organization
  belongs_to :company_strength
  has_many :deals, :dependent => :nullify, :primary_key => "contact_ref_id", :foreign_key => "contact_id"
  has_one :address, :as => :addressable,:class_name=>"Address", :dependent => :destroy
  has_many :phones, :as => :phoneble, :dependent => :destroy
  has_many :work_phones, :as => :phoneble,:class_name=>"Phone", :conditions => { :phone_type => 'work'}
  has_one :image,:class_name=>"Image",:as=>:imagable, :dependent => :destroy
  has_many :attachments,:class_name=>"Note",:as=>:notable, :dependent => :destroy
  has_many :tasks, :as=> :taskable, :dependent => :destroy
  has_many :deals_contacts, :as => :contactable,:class_name=>"DealsContact", :dependent => :destroy
  belongs_to :initiator,:class_name=>"User",:foreign_key=>"created_by"
  has_many :individual_contacts, :dependent => :nullify
  has_many :secondary_companies, :dependent => :destroy
  attr_accessible :name,:country,:work_phone,:mobile_number,:email, :messanger_type, :messanger_id, :website,
                 :linkedin_url, :facebook_url, :twitter_url, :organization, :organization_id,
                 :email, :company_strength_id,:created_by, :is_public,
                 :street, :city, :state, :zip_code, :company_strength, :extension, :contact_image, :time_zone, :country_id, :total_opportunities, :total_open_opportunities, :company_industry_id
  alias_attribute :full_name, :name
  attr_accessor :work_phone,:contact_id,:note,:file_description,:attachment,  :city,
        :state, :zip_code,:mobile_number,:contact_image, :street, :extension
  has_many :individual_contacts, :dependent => :destroy
  # has_many :activities, :class_name=>"Activity", :dependent => :destroy,:foreign_key=>"source_id"
  has_many  :activities_contacts,:as => :contactable, :dependent => :destroy,:class_name=>"ActivitiesContact"
  has_many :projects
  has_many :project_jobs, :as => :contactable
  belongs_to :country
   
  belongs_to :owner,:class_name=>"User",:foreign_key=>"created_by"
  
  scope :by_contact_type, lambda{|type| where("contact_type = ? ", type)}  
  scope :by_organization_id, lambda{|org_id| where("organization_id = ? ", org_id)}  
  ## disabled public deals view by normal user
  #scope :by_visibilty, lambda{|org_id,user_id| where("organization_id = ? and (is_public = true or (is_public = false and created_by=?))", org_id,user_id) }  
  scope :by_visibilty, lambda{|org_id,user_id| where("organization_id = ? and (created_by=?)", org_id,user_id) }    
  scope :search_by, lambda{|data| where("name REGEXP ? or email REGEXP ?", data, data)}
  scope :by_first_letter,   lambda{|type| where("name like ?", type + '%' )}  
  scope :by_first_letter_name,   lambda{|type| where("name like ?", type + '%' )}  
  scope :by_alpha_firstname,   lambda{where("name REGEXP '^[^A-Za-z]' " )}  
  scope :by_alpha_name,   lambda{ where("name REGEXP '^[^A-Za-z]' ")}  
  validates :name, :uniqueness => {:scope => :organization_id, message: "has already been taken!"}, :allow_blank => false
  validates :email, :uniqueness =>  {scope: :organization_id, message: "has already been taken!"}, :allow_blank => true
  encrypted_id key: 'b0b38fc4628c12981200f0189e7be8f95a9c'
  #after_save :save_other_info
  #after_update :save_other_info
  before_create :set_messanger
  # after_save :save_to_phone
  def set_messanger
    self.messanger_type = "Skype"
  end

  def save_to_phone
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
  end
   
  # Decrypted Company Contact ID #
  def self.to_decrypt_key encrypted_key
    begin
      key = EncryptedId.decrypt(CompanyContact.first.class.encrypted_id_key, encrypted_key)
      key
    rescue
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
         
         puts "==========> "
         p dc.deal.present?
         p deal
         
         p deal.deals_contacts.count
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
  def is_individual?
    false
  end
  
  def is_company?
    true
  end

  def full_name
    "#{name}"
  end
  
  ##for dasboard activity 
  def title
    "#{name}"
  end
  
  def contact_name
    "#{name}"
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
  
  def email_field
    (self.email.present? ? self.email : "")
  end
  
  ## Stuffs for elasitic search functionality
    
  #include Tire::Model::Search
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
  #end
  
#  def to_indexed_json
#    to_json(:methods => [:title, :image_url])
#  end
  def to_indexed_json
    to_json( 
      #:only   => [ :id, :name, :normalized_name, :url ],
     :methods   => [:title,:email_field,:image_url,:initiator_name, :phone_number, :country_name, :country_id, :contact_status, :contacts_name, :contacts_email, :contacts_phone_no]
    )
  end
  
  def image_url
    #if self.image.present?
    #  image.image.url(:icon)
    #else
    #  "/assets/no_user.png"
    #end
    "#{ENV['cloudfront']}/assets/comp_logo.png"
  end
  
  def initiator_name
    initiator.present? ? initiator.full_name : ""
  end
  
  def phone_number
    phones.present? ? phones.first.phone_no : ""
  end
  
  def country_name
  
    (self.address.present? && self.address.country.present?) ? self.address.country.name : (country.present? ? Country.find(country).name : 1)
  end
  
  def country_id
    (self.address.present? && self.address.country.present?) ? self.address.country.id : country
  end
  
  def contact_status
    self.is_active? ? true : false
  end
  
  def contact_status_disabled
    self.is_active? ? 1 : 0
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

  def self.get_org_location id
    contact = CompanyContact.find(id)
    location=""
    if contact.present? && (address = contact.address).present?
      location += address.address + ", " if address.address.present?
      location += address.city + ", " if address.city.present?
      location += address.state + ", " if address.state.present?
      location += address.country.name if address.country.present?
    end
    return location
  end

  def self.get_phone id
    contact = CompanyContact.find(id)
    location=""
    if contact.present? && (phones = contact.phones).present?
      phones.by_phone_type("work")
    else
      nil
    end
  end
  def get_project_count
    self.projects.count
  end

  def self.get_projects_count id
    contact = CompanyContact.find(id)
    contact.projects.count
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

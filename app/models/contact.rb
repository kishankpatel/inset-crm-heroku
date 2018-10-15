# == Schema Information
#
# Table name: contacts
#
#  id                  :integer          not null, primary key
#  organization_id     :integer
#  name                :string(255)
#  company_strength_id :integer
#  contact_type        :string(255)
#  first_name          :string(255)
#  last_name           :string(255)
#  email               :string(255)
#  website             :string(255)
#  messanger_type      :string(255)
#  messanger_id        :string(255)
#  linkedin_url        :string(255)
#  facebook_url        :string(255)
#  twitter_url         :string(255)
#  is_public           :boolean
#  created_by          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  is_active           :boolean          default(TRUE)
#

class Contact < ActiveRecord::Base
  belongs_to :organization
  belongs_to :company_strength
  has_many :deals, :dependent => :nullify
  has_one :address, :as => :addressable,:class_name=>"Address", :dependent => :destroy
  has_many :phones, :as => :phoneble, :dependent => :destroy
  has_one :image,:class_name=>"Image",:as=>:imagable, :dependent => :destroy
  has_many :attachments,:class_name=>"Note",:as=>:notable, :dependent => :destroy
  has_many :tasks, :as=> :taskable, :dependent => :destroy
  has_many :invoices
  has_many :deals_contacts, :as=>:contactable
  belongs_to :initiator,:class_name=>"User",:foreign_key=>"created_by"
    
  #include Tire::Model::Search
  #include Tire::Model::Callbacks
  
 # mapping do
  #  indexes :title,      type: 'string'
   # indexes :image_url
    #indexes :initiator_name
    #indexes :phone_number
    #indexes :country_name
  #end
  
#  def to_indexed_json
#    to_json(:methods => [:title, :image_url])
#  end
  ### Export CSV ###
  def self.to_csv(org_id)
    org = Organization.find_by_id org_id
    @all_contacts = org.individual_contacts + org.company_contacts
    @contacts = @all_contacts.sort_by{|e| e[:created_at]}
    CSV.generate do |csv|
      csv << ["Name", "Email", "Contact Type", "Last Touch", "Leads", "Tasks", "Last Lead", "Last Task", "Open Opportunities", "No. of Projects"] ## Header values of CSV
      @contacts.each do |contact|
        if contact.class.name == "IndividualContact"
          cont_type = "individual"
        else
          cont_type = "company"
        end
        csv << [cont_type == "company" ? contact.name : contact.full_name,
                contact.email, 
                cont_type,
                contact.updated_at,
                contact.deals_contacts.count,
                contact.tasks.count,
                contact.deals_contacts.last.present? ? (contact.deals_contacts.last.deal.present? ? contact.deals_contacts.last.deal.title : "NA" ) : "NA",
                contact.tasks.last.present? ? contact.tasks.last.title : "NA",
                cont_type == "individual" ? (contact.deals_contacts.map{|dc| dc.deal if dc.deal.present? && dc.deal.is_active && (dc.deal.is_won == "" || dc.deal.is_won == nil)}.compact.count) : contact.total_open_opportunities,
                cont_type == "individual" ? contact.get_project_count : CompanyContact.get_projects_count(contact.id)] ##Row values of CSV
      end
    end
  end
  def to_indexed_json
    to_json( 
      #:only   => [ :id, :name, :normalized_name, :url ],
      :methods   => [:title, :image_url, :initiator_name, :phone_number, :country_name]
    )
  end
  
  def image_url
    if self.image.present?
      image.image.url(:icon)
    else
      "/assets/no_user.png"
    end
  end
  
  def initiator_name
    initiator.present? ? initiator.full_name : ""
  end
  
  def phone_number
    phones.present? ? phones.first.phone_no : ""
  end
  
  def country_name
    address.present? && address.country.present? ? address.country.name : ""
  end
  attr_accessible :created_by, :email, :facebook_url, :first_name, :is_public, :last_name, :linkedin_url, :messanger_id, 
              :messanger_type, :name, :twitter_url, :website,:organization,:organization_id,:company_strength_id,:contact_type,:created_at
              
              
  attr_accessor :country,:work_phone,:contact_id,:note,:file_description,:attachment,  :city,
          :state, :zip_code,:mobile_number,:contact_image, :full_address
          
  
  scope :by_contact_type, lambda{|type| where("contact_type = ? ", type)}  
  scope :by_organization_id, lambda{|org_id| where("organization_id = ? ", org_id)}  
  ## disabled public deals view by normal user
  #scope :by_visibilty, lambda{|org_id,user_id| where("organization_id = ? and (is_public = true or (is_public = false and created_by=?))", org_id,user_id) }  
  scope :by_visibilty, lambda{|org_id,user_id| where("organization_id = ? and (created_by=?)", org_id,user_id) }   
  scope :search_by, lambda{|data| where("name REGEXP ? or first_name REGEXP ? or last_name REGEXP ? or email REGEXP ?", data,data, data,data)}         
  scope :by_first_letter,   lambda{|type| where("first_name like ?", type + '%' )}  
  scope :by_first_letter_name,   lambda{|type| where("name like ?", type + '%' )}  
  scope :by_alpha_firstname,   lambda{where("first_name REGEXP '^[^A-Za-z]' " )}  
  scope :by_alpha_name,   lambda{ where("name REGEXP '^[^A-Za-z]' ")}  
          
  def full_name
    "#{first_name} #{last_name}"
  end
  
  ##for dasboard activity 
  def title
    "#{first_name} #{last_name}"
  end
  
  def self.get_color_code char
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
      color = "#FF8A65"
    end
    return color
  end
end

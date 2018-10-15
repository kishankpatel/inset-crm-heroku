# == Schema Information
#
# Table name: temp_leads
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  title        :text
#  priority     :string(255)
#  company_name :string(255)
#  company_size :string(255)
#  website      :string(255)
#  contact_name :string(255)
#  designation  :string(255)
#  phone        :string(255)
#  extension    :string(255)
#  mobile       :string(255)
#  email        :string(255)
#  technology   :string(255)
#  source       :text
#  location     :string(255)
#  country      :string(255)
#  industry     :string(255)
#  comments     :text
#  created_dt   :datetime
#  description  :text
#  assigned_to  :string(255)
#  facebook_url :string(255)
#  linkedin_url :string(255)
#  twitter_url  :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  skype_id     :string(255)
#  task_type    :string(255)
#

class TempLead < ActiveRecord::Base
  strip_attributes #automatically strips all attributes of leading and trailing whitespace
  
        attr_accessible :assigned_to, :comments, :company_name, :company_size, :contact_name,
         :country, :created_dt, :description, :designation, :email, :industry, :location, 
         :mobile, :phone, :priority, :source, :task_type, :technology, :title, 
         :user_id, :website,:facebook_url, :linkedin_url, :twitter_url, :extension,:skype_id, :task_type

  scope :by_user,  lambda{|user_id| where("user_id   = ? ", user_id)}  
 
 
  before_create :remove_break_line
 
 def remove_break_line
     #self.designation = designation.gsub("\n",' ') if designation.present?
     #self.location = location.gsub("\n",' ') if location.present?
     self.designation = designation.squish if designation.present?
     self.location = location.squish if location.present?
     self.company_name = company_name.squish if company_name.present?
     self.contact_name = contact_name.squish if contact_name.present?
 end
 
 
 
end

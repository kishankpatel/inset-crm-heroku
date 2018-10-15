# == Schema Information
#
# Table name: activities
#
#  id               :integer          not null, primary key
#  organization_id  :integer
#  activity_type    :string(255)
#  activity_id      :integer
#  activity_user_id :integer
#  activity_status  :string(255)
#  activity_desc    :string(255)
#  activity_date    :datetime
#  is_public        :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  source_id        :integer
#  is_available     :boolean          default(FALSE)
#  activity_by      :integer
#  source_type      :string(255)
#

class Activity < ActiveRecord::Base

  attr_accessible :activity_type, :activity_id, :activity_user_id, :activity_status, :activity_desc, 
  :activity_date, :is_public, :organization_id, :source_id, :activity_by,:source_type


  scope :by_range, lambda{ |start_date, end_date| where(:activity_date => start_date..end_date) }

  #has_many :users, :class_name=>"User" ,:foreign_key=>"activity_user_id"
  belongs_to :user, :class_name=>"User" ,:foreign_key=>"activity_user_id"
  # has_many :deals, :class_name=>"Deal" ,:foreign_key=>"source_id"
  belongs_to :source, polymorphic: true
  has_many :activities_contacts
  has_many :sent_email_opens
end

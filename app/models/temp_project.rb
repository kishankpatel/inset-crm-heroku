# == Schema Information
#
# Table name: temp_projects
#
#  id               :integer          not null, primary key
#  organization_id  :integer
#  user_id          :integer
#  name             :string(255)
#  short_name       :string(255)
#  start_date       :date
#  end_date         :date
#  opportunity      :string(255)
#  contact_email    :string(255)
#  estimate_hour    :integer
#  default_job_type :string(255)
#  description      :text
#  team_emails      :string(255)
#  is_completed     :boolean
#  stage            :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TempProject < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  scope :by_user,  lambda{|user_id| where("user_id   = ? ", user_id)}  
  attr_accessible :contact_email, :default_job_type, :description, :end_date, :estimate_hour, :is_completed, :name, :opportunity, :short_name, :stage, :start_date, :team_emails,:organization_id,:user_id
end

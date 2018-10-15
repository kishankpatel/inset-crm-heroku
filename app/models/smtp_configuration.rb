# == Schema Information
#
# Table name: smtp_configurations
#
#  id              :integer          not null, primary key
#  smtp_host       :string(255)
#  port            :string(255)
#  email           :string(255)
#  user_name       :string(255)
#  password        :string(255)
#  organization_id :integer
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class SmtpConfiguration < ActiveRecord::Base
  attr_accessible :email, :organization_id, :password, :port, :smtp_host, :user_id, :user_name
  belongs_to :user
  belongs_to :organization
end

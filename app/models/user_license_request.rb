# == Schema Information
#
# Table name: user_license_requests
#
#  id                   :integer          not null, primary key
#  customer_id          :integer
#  name                 :string(255)
#  email                :string(255)
#  requested_user_limit :integer
#  amount               :integer
#  is_license_generated :boolean          default(FALSE)
#  new_license_key      :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class UserLicenseRequest < ActiveRecord::Base
  belongs_to :self_hosting_user, :primary_key => "customer_id", :foreign_key => "customer_id"
  attr_accessible :amount, :customer_id, :email, :is_license_generated, :name, :new_license_key, :requested_user_limit
  after_create :update_data

  def update_data
  	self.update_attributes(:is_license_generated => true)
  end
end

# == Schema Information
#
# Table name: user_subscriptions
#
#  id                      :integer          not null, primary key
#  subscription_id         :integer
#  user_limit              :integer
#  storage_limit           :integer
#  price                   :float
#  btsubscription_id       :text
#  btprofile_id            :text
#  cc_token                :text
#  payment_status          :string(255)
#  is_cancel               :boolean          default(FALSE)
#  is_updown               :string(255)
#  subscription_start_date :datetime
#  next_billing_date       :datetime
#  cancel_date             :datetime
#  is_active               :boolean          default(TRUE)
#  organization_id         :integer
#  user_id                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class UserSubscription < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :transactions
  attr_accessible :organization_id, :user_id, :btprofile_id, :btsubscription_id, :cancel_date, :cc_token, :is_active, :is_cancel, :is_updown, :next_billing_date, :payment_status, :price, :storage_limit, :subscription_id, :subscription_start_date, :user_limit, :is_cancel_payment_fail, :is_grace_active, :grace_period_ends_on

  scope :active, lambda {where("is_active = ?", true)}  

  after_save :update_org_data
  after_save :adjust_org_user_limit, :if => :is_active_changed?


  def update_org_data
 	  # self.organization.update_column(:is_sub_active, self.is_active) 
 	  # if self.is_updown == 'started'
 	  # 	self.organization.update_attributes :current_sub_id => self.id, :is_sub_active => self.is_active, :current_user_limit => self.user_limit #, :trial_expires_on => Time.now
 	  # else
 	  self.organization.update_attributes :current_sub_id => self.id, :is_sub_active => self.is_active, :current_user_limit => self.user_limit
 	  # end
  end

  def adjust_org_user_limit  	  	
  	  self.organization.update_column(:current_user_limit, nil)  unless self.is_active
  end
  
end

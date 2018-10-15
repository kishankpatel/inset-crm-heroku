# == Schema Information
#
# Table name: user_hourly_billables
#
#  id              :integer          not null, primary key
#  amount          :integer
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class UserHourlyBillable < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :amount, :organization
end

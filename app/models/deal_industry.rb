# == Schema Information
#
# Table name: deal_industries
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  deal_id         :integer
#  industry_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class DealIndustry < ActiveRecord::Base
  belongs_to :organization
  belongs_to :deal
  belongs_to :industry
  attr_accessible :organization,:deal,:industry,:industry_id,:deal_id,:organization_id
end

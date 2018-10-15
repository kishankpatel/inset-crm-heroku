# == Schema Information
#
# Table name: opportunities
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  user_id         :integer
#  year            :integer
#  quarter         :integer
#  total_deals     :integer
#  won_deals       :integer
#  win             :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Opportunity < ActiveRecord::Base
  attr_accessible :organization_id, :quarter, :total_deals, :user_id, :win, :won_deals, :year
end

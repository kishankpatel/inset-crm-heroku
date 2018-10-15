# == Schema Information
#
# Table name: sales_cycles
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  user_id         :integer
#  year            :integer
#  quarter         :integer
#  average         :integer
#  shortest        :integer
#  longest         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class SalesCycle < ActiveRecord::Base
  attr_accessible :average, :longest, :organization_id, :quarter, :shortest, :user_id, :year
end

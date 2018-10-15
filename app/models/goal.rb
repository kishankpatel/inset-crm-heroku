# == Schema Information
#
# Table name: goals
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  user_id         :integer
#  goal_type       :string(255)
#  deal_stage_id   :integer
#  period          :string(255)
#  quantity_deal   :integer
#  value           :string(255)
#  currency        :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Goal < ActiveRecord::Base
  attr_accessible :organization_id, :user_id, :goal_type, :deal_stage_id, :period, :quantity_deal, :value, :currency
  belongs_to :user
  has_many :user_goals
end

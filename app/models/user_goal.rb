# == Schema Information
#
# Table name: user_goals
#
#  id         :integer          not null, primary key
#  goal_id    :integer
#  user_id    :integer
#  deal_id    :integer
#  amount     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserGoal < ActiveRecord::Base
  attr_accessible :user_id, :goal_id, :deal_id,:amount
end

# == Schema Information
#
# Table name: task_priority_types
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  original_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TaskPriorityType < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :original_id
end

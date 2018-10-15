# == Schema Information
#
# Table name: task_outcomes
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  task_out_type   :string(255)
#  task_duration   :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#

class TaskOutcome < ActiveRecord::Base
   attr_accessible :name, :task_out_type, :task_duration,:organization_id
   belongs_to :organization
end

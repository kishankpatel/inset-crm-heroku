# == Schema Information
#
# Table name: project_job_groups
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :integer
#

class ProjectJobGroup < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :organization_id,:project_id
  belongs_to :project
  
  validates :name, :uniqueness => {:scope => [:organization_id, :project_id], :case_sensitive => false}
end

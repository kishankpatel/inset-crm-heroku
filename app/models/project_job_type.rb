# == Schema Information
#
# Table name: project_job_types
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  original_id     :integer
#

class ProjectJobType < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :organization_id,:original_id
  validates :name, :uniqueness => {:scope => :organization_id, :case_sensitive => false}
end

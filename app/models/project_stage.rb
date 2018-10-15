# == Schema Information
#
# Table name: project_stages
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  is_active       :boolean
#  position        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  original_id     :integer
#

class ProjectStage < ActiveRecord::Base
  belongs_to :organization
  has_many :projects
  before_destroy :check_for_original_id,:check_if_projects_present?
  attr_accessible :is_active, :name, :position,:organization_id,:original_id  
  private
  def check_if_projects_present?
    puts "coming to check before destroy ............................"
    return true if self.projects.count == 0
    errors.add :base, "Cannot delete project stage.Projects exists for this!!"
    false
  end
  def check_for_original_id   
    unless original_id.nil?     
      self.errors[:base] << "Cannot delete default project stage."
      return false   
    end 
  end 

end

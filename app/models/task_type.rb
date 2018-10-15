# == Schema Information
#
# Table name: task_types
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  original_id     :integer
#

class TaskType < ActiveRecord::Base
  attr_accessible :name, :organization_id,:original_id
  
  belongs_to :organization
  has_many :tasks
  before_destroy :check_if_tasks_present?
  TASK_COLORS={"Appointment"=>"#FAA732", "Billing"=> "#999966", "Call" => "#49AFCD", "Documentation" => "#3399FF", "Email" => "#0099CC", "Follow-up" => "#DA4F49", "Meeting" => "#5F04B4", "None" => "#A4A4A4", "Quote" => "#763532", "Thank-you" => "#5BB75B"}
  private
  def check_if_tasks_present?
    puts "coming to check before destroy ............................"
    return true if self.tasks.count == 0
    errors.add :base, "Cannot delete Task Types. Tasks exists for this!!"
    false
  end
end

# == Schema Information
#
# Table name: project_users
#
#  id         :integer          not null, primary key
#  project_id :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectUser < ActiveRecord::Base
  include ProjectJobsHelper
  attr_accessible :project_id, :user_id
  belongs_to :project
  belongs_to :user
  has_many :project_jobs, :dependent=>:nullify,:foreign_key=>"assigned_to",:through=>:project
  belongs_to :associated_user, :class_name=>"User",:foreign_key=>"user_id"
  has_many :job_time_logs, :through=>:project, :dependent=>:nullify
  def billable_hours(formated = true)
    if(self.job_time_logs.present?)
      jtls_count = self.job_time_logs.where(:is_billable=>true).select("sum(COALESCE(spent_hours,0)) as spent_hours").first
      if(jtls_count.present? && jtls_count.spent_hours.present?)
        if(formated)
          return getHourMinuteFromSeconds(jtls_count.spent_hours)
        else
          return jtls_count.spent_hours / 3600.0
        end
      else
        return 0
      end
    else
      return 0
    end
  end
  def nonbillable_hours(formated = true)
    if(self.job_time_logs.present?)
      jtls_count = self.job_time_logs.where(:is_billable=>false).select("sum(COALESCE(spent_hours,0)) as spent_hours").first
      if(jtls_count.present? && jtls_count.spent_hours.present?)
        if(formated)
          return getHourMinuteFromSeconds(jtls_count.spent_hours)
        else
          return jtls_count.spent_hours / 3600.0
        end
      else
        return 0
      end
    else
      return 0
    end
  end
end

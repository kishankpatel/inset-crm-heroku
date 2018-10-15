# == Schema Information
#
# Table name: job_time_logs
#
#  id              :integer          not null, primary key
#  project_job_id  :integer
#  user_id         :integer
#  log_start_time  :datetime
#  log_end_time    :datetime
#  break_time      :integer
#  spent_hours     :integer
#  note            :text
#  is_billable     :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#

class JobTimeLog < ActiveRecord::Base
  belongs_to :project_job,:touch=>true
  belongs_to :user
  belongs_to :organization
  ## spent_hours is saved in seconds
  attr_accessible :break_time, :is_billable, :log_end_time, :log_start_time, :note, :spent_hours,:job_time_log_attributes,:project_job_id,:user_id,:no_log_time,:organization_id

  attr_accessor :log_start_date  
  def self.get_timesheet(user,start_date,end_date)
    return self.where("user_id = ? ",user.id).where("log_start_time between ? and ? " ,start_date,end_date).select("sum(COALESCE(spent_hours,0)) spent_hours,log_start_time,project_job_id, case log_start_time=log_end_time when true then 1 else 0 end as no_log_time,is_billable").group("log_start_time,project_job_id")
  end
end

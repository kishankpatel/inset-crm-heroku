# == Schema Information
#
# Table name: project_job_repeats
#
#  id                 :integer          not null, primary key
#  created_by         :integer
#  repeat_type        :string(255)
#  repeat_start       :datetime
#  repeat_end_on      :datetime
#  repeat_occurrences :integer
#  organization_id    :integer
#  project_job_id     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ProjectJobRepeat < ActiveRecord::Base
  belongs_to :organization
  belongs_to :project_job
  attr_accessible :created_by, :repeat_end_on, :repeat_occurrences, :repeat_start, :repeat_type, :organization_id, :project_job_id

  after_create :recurring_job

  def recurring_job
  	case self.repeat_type
  	when "weekly"
		create_recurring_job(self,1.week)
  	when "monthly"
  		create_recurring_job(self,1.month)
	when "quarterly"
		create_recurring_job(self,6.month)
	when "yearly"
		create_recurring_job(self,1.year)
	end
  end

  def create_recurring_job(job_repeat,duration)
  	job = job_repeat.project_job
  	occurrences = job_repeat.repeat_occurrences
  	end_on = job_repeat.repeat_end_on
  	if end_on.present?
  		new_task = ""
  		start_date = job_repeat.repeat_start
  		job_start_date = job.start_date
	  	job_due_date = job.due_date
  		i = 0
  		while (start_date + duration) < end_on do
  			start_date = (i == 0 ? start_date :  (start_date + duration))
  			new_task = ProjectJob.create(job.attributes.merge({:name => job.name + " - " + (i + 1).to_s, :start_date => start_date, :due_date => job_due_date.present? ? (start_date + ((job_due_date.to_date - job_start_date.to_date).to_i).days) : ""}))
		  	start_date = new_task.start_date
		  	i +=1
		end
	else
		if occurrences.present?
	  		i = 0
	  		new_task = ""
	  		start_date = job_repeat.repeat_start
	  		job_start_date = job.start_date
	  		job_due_date = job.due_date
	  		while i < occurrences do
	  			start_date = (i == 0 ? start_date :  (start_date + duration))
				new_task = ProjectJob.create(job.attributes.merge({:name => job.name + " - " + (i + 1).to_s, :start_date => start_date, :due_date => job_due_date.present? ? (start_date + ((job_due_date.to_date - job_start_date.to_date).to_i).days) : ""}))
	  			start_date = new_task.start_date
	  			i +=1
			end
		end
	end
  end
end


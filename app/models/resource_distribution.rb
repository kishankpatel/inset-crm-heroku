# == Schema Information
#
# Table name: resource_distributions
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  project_job_id  :integer
#  user_id         :integer
#  allotted_date   :datetime
#  allotted_time   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#

class ResourceDistribution < ActiveRecord::Base
  belongs_to :project
  belongs_to :project_job
  belongs_to :user
  belongs_to :organization
  ##allotted_time is saved in minutes
  attr_accessible :allotted_time, :allotted_date,:project_id,:project_job_id,:user_id,:organization_id
  def self.resource_allocations start_date, end_date,user_id=0,project_job_id=0,project_id=0
    # p start_date, end_date,user_id,project_job_id,project_id
    if(user_id == 0 && project_job_id == 0 && project_id == 0)
      puts "coming to condition 1:........user_id == 0 && project_job_id == 0 && project_id == 0 "
      return self.includes(:user,:project,:project_job).where("allotted_date between ? and ?",start_date,end_date).select("sum(allotted_time) as allotted_time,allotted_date,user_id,project_id,project_job_id").group(:user_id,:allotted_date,:project_id,:user_id,:project_job_id).all
    elsif user_id != 0 && project_job_id != 0 
      puts "coming to condition 2:........user_id != 0 &&  project_job_id != 0 "
      return self.where(:user_id=>user_id).where("project_job_id = ?  ",project_job_id).select("sum(allotted_time) as allotted_time,allotted_date,user_id,project_id,project_job_id").group(:user_id,:allotted_date,:project_id,:user_id,:project_job_id).all
    elsif(user_id == 0 && project_id != 'all')
      puts "coming to condition 3:........ user_id == 0 && project_id != 'all'"
      return self.where(:user_id=>user_id,:project_id=>project_id).where("allotted_date between ? and ?",start_date,end_date).select("sum(allotted_time) as allotted_time,allotted_date,project_id,project_job_id").group(:allotted_date,:project_id,:user_id,:project_job_id).all
    elsif(user_id != 0 && project_id != 'all')
      puts "coming to condition 4:........ user_id != 0 && project_id != 'all'"
      return self.where(:user_id=>user_id,:project_id=>project_id).where("allotted_date between ? and ?",start_date,end_date).select("sum(allotted_time) as allotted_time,allotted_date,project_id,project_job_id").group(:allotted_date,:user_id).all
    elsif(user_id != 0 && project_id == 'all')
      puts "coming to condition 5:........ user_id != 0 && project_id == 'all'"
      archived_projects =  User.current.organization.projects.archived.map(&:id)
      if(archived_projects.present?)
        return self.includes(:project,:project_job).where(:user_id=>user_id).where("allotted_time > 0 and allotted_date between ? and ?",start_date,end_date).where("project_id not in (?)",archived_projects).select("sum(allotted_time) as allotted_time,allotted_date,project_id,project_job_id").group(:allotted_date,:project_id,:project_job_id).all
      else
        return self.includes(:project,:project_job).where(:user_id=>user_id).where("allotted_time > 0 and allotted_date between ? and ?",start_date,end_date).select("sum(allotted_time) as allotted_time,allotted_date,project_id,project_job_id").group(:allotted_date,:project_id,:user_id,:project_job_id).all
      end
    end
  end
  def self.get_projects start_date, end_date,user_id=0,project_job_id=0,project_id='0'
    project_ids = []
    if(user_id == 0 && project_job_id == 0)
      puts "get projects : condition 1 :................(user_id == 0 && project_job_id == 0)"
      project_ids = self.where("allotted_date between ? and ?",start_date,end_date).select("project_id").all.map(&:project_id)
    elsif project_job_id != 0 
      puts "get projects : condition 2 :................project_job_id != 0 "
      project_ids = self.where("project_job_id = ? and  allotted_date between ? and ? ",project_job_id,start_date,end_date).select("project_id").all.map(&:project_id)
    elsif(user_id != 0 && project_id != 'all' && project_id != 0)
      puts "get projects : condition 3 :................user_id != 0 && project_id != 'all' && project_id != 0"
      
      project_ids = self.where(:user_id=>user_id).where("allotted_date between ? and ?",start_date,end_date).select("project_id").all.map(&:project_id)
    elsif(project_id == 'all' || project_id == 0)
      puts "get projects : condition 4 :................project_id == 'all' || project_id == 0"
      archived_projects =  User.current.organization.projects.archived.map(&:id)
      if(archived_projects.present?)
        project_ids = self.includes(:project).where(:user_id=>user_id).where("allotted_time > 0 and allotted_date between ? and ?",start_date,end_date).where("project_id not in (?)",archived_projects).select("project_id").all.map(&:project_id)
      else
        project_ids = self.includes(:project).where(:user_id=>user_id).where("allotted_time > 0 and allotted_date between ? and ?",start_date,end_date).select("project_id").all.map(&:project_id)
      end
    end
    return Project.where("id in (?)",project_ids ).all
  end
end

# == Schema Information
#
# Table name: projects
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  short_name            :string(255)
#  start_date            :datetime
#  end_date              :datetime
#  estimate_hour         :time
#  created_by            :integer
#  status                :string(255)
#  description           :text
#  deal_id               :integer
#  organization_id       :integer
#  individual_contact_id :integer
#  project_task_type_id  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  is_completed          :boolean          default(FALSE)
#  is_archive            :boolean          default(FALSE)
#  is_accessible         :boolean          default(TRUE)
#  project_stage_id      :integer
#  project_manager_id    :integer
#  company_contact_id    :integer
#  linked_with           :string(255)
#  project_type          :string(255)
#

class Project < ActiveRecord::Base
  include ProjectJobsHelper
  belongs_to :deal
  belongs_to :individual_contact, :dependent => :destroy
  belongs_to :company_contact #,:dependent =>:destroy
  belongs_to :organization
  has_many :project_users, :dependent => :destroy
  has_many :project_jobs, :dependent => :destroy
  belongs_to :created_user, :class_name=>"User",:foreign_key=>"created_by"
  belongs_to :project_stage
  has_many :job_time_logs, :through=> :project_jobs
  has_many :invoices,:dependent=> :nullify
  has_many :project_job_groups
  has_many :activities, :class_name=>"Activity", :dependent => :destroy, :as=> :source #, :foreign_key=>"source_id"
  belongs_to :project_manager, :class_name =>"User",:foreign_key=>"project_manager_id"
  has_many :mail_letters, :as => :mailable
  attr_accessible :organization_id, :created_by, :end_date, :name, :start_date, :status, :string, :deal_id, :short_name, :individual_contact_id, :estimate_hour, :project_task_type_id, :description, :project_users_attributes, :is_completed,:project_stage_id,:project_manager_id,:company_contact_id, :linked_with,:is_accessible,:project_type
  accepts_nested_attributes_for :project_users, :reject_if => proc { |att| att['user_id'].nil? }, :allow_destroy => true
  after_create :update_lead
  default_scope where(:is_archive => false, :is_accessible => true)
  scope :archived, -> { where(is_archive: true) }
  validate :project_manager_must_be_admin
  validates :name, uniqueness: { scope: :organization_id, message: "should be unique" }
  validates :short_name, uniqueness: { scope: :organization_id, message: "should be unique" }
  before_destroy :destroy_all_project_jobs

  # validates_uniqueness_of :name,:short_name
  def project_manager_must_be_admin
    if(!self.project_manager_id.present?)
      errors.add(:project_manager_id, 'must be present')
    elsif(self.project_manager_id.present?)
      u = User.where(:id=>self.project_manager_id).first
      if(!u.present?)
        errors.add(:project_manager_id, 'must be a valid user')
      end
      if(u.present? && (!u.is_admin? && !u.is_super_admin?))
        errors.add(:project_manager_id, 'only a admin can be a project manager')
      end
    end
  end
  def update_lead
  	self.deal.update_attributes(:is_project => true, :project_id => self.id) if self.deal.present?
  end

  def destroy_all_project_jobs
    jobs = self.project_jobs
    if jobs.present?
      jobs.destroy_all
    end
  end

  def self.active_multi_filter(params)   
    query=""
    prio=false
    
    if params[:cre_by] == true || params[:cre_by] == "true"
      if params[:cre_by_val].present? && (cre=params[:cre_by_val].split('|')).present? && (cre_ids=cre.join(','))
        query += "`projects`.`created_by` IN (#{cre_ids})"
      end
    end
    if params[:asg_by] == true || params[:asg_by] == "true"
      query += " and "if query.present?
      if params[:asg_by_val].present? && (asg=params[:asg_by_val].split('|')).present? && (asg_ids=asg.join(','))#&& (asg_ids = asg.map{|a| a.to_i})
        query += "`projects`.`assigned_to` IN (#{asg_ids})"
      end
    end

    if params[:lead] == true || params[:lead] == "true"
      query += " and "if query.present?
      if params[:lead_val].present? && (lead=params[:lead_val].split('|')).present? && (lead_ids=lead.join(','))
        query += "`projects`.`deal_id` IN (#{lead_ids})"
      end
      lead=true
    end
   
    if params[:daterange] == "true"
      query += " and "if query.present?
      if params[:dt_range] == "Past Week"
         startdate = 1.week.ago.beginning_of_week.strftime("%Y-%m-%d")
         enddate = 1.week.ago.end_of_week.strftime("%Y-%m-%d")
      elsif params[:dt_range] == "Past Two Weeks"
         startdate = 2.week.ago.beginning_of_week.strftime("%Y-%m-%d")
         enddate = 1.week.ago.end_of_week.strftime("%Y-%m-%d")
      elsif params[:dt_range] == "Past Three Weeks"
         startdate = 3.week.ago.beginning_of_week.strftime("%Y-%m-%d")
         enddate = 1.week.ago.end_of_week.strftime("%Y-%m-%d")
      elsif params[:dt_range] == "Past Month"
         startdate = 1.month.ago.beginning_of_month.strftime("%Y-%m-%d")
         enddate = 1.month.ago.end_of_month.strftime("%Y-%m-%d")
      elsif params[:dt_range] == "Past Year"
         startdate = DateTime.new(Time.zone.now.year-1,1,1).strftime("%Y-%m-%d")
         enddate = DateTime.new(Time.zone.now.year-1,12,31).strftime("%Y-%m-%d")
      elsif params[:dt_range] == "3m"
         startdate = 3.months.ago.beginning_of_month.strftime("%Y-%m-%d")
         enddate = 3.months.ago.end_of_month.strftime("%Y-%m-%d")
      end      
      query += "`projects`.`created_at` BETWEEN '#{startdate}' AND '#{enddate}'"
    end
    
     if ((params[:dtrange_from] == true || params[:dtrange_from] == "true") && (params[:dtrange_to] == true || params[:dtrange_to] == "true"))
      query += " and "if query.present?
      frmdate = Date.parse(params[:dt_range_from]).strftime("%Y-%m-%d")
      todate = Date.parse(params[:dt_range_to]).strftime("%Y-%m-%d")
      query += "`projects`.`created_at` BETWEEN '#{frmdate}' AND '#{todate}'"
     end

    if params[:last_tch] == "true"
      query += " and "if query.present?
      if params[:last_touch] == "Last Week"
        last_d = (DateTime.now - 7.days).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Two Weeks"
        last_d = (DateTime.now - 14.days).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Three Weeks"
        last_d = (DateTime.now - 21.days).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Month"
        last_d = (DateTime.now - 1.month).strftime("%Y-%m-%d")
      elsif params[:last_touch] == "Last Three Months"
        last_d = (DateTime.now - 3.month).strftime("%Y-%m-%d")
      end
     query += "`projects`.`updated_at` < '#{last_d}'"
    end
    if params[:status] == true || params[:status] == "true"
      query += " and "if query.present?
      if params[:status_val].present? && (status=params[:status_val].split('|')).present? && (statuses=status.join(','))
        query += "`projects`.`status` IN (#{statuses})"
      end
      stage = true
    end
    where(query).order("created_at desc")
  end
  def logged_hours(formated = true)
    if(self.job_time_logs.present?)
      jtls_count = self.job_time_logs.select("sum(COALESCE(spent_hours,0)) as spent_hours").first
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
  def billable_hours(formated = true)
    if(self.job_time_logs.present?)
      jtls_count = self.job_time_logs.where(:is_billable=>true).select("sum(COALESCE(spent_hours,0)) as spent_hours").first
      if(jtls_count.present? && jtls_count.spent_hours.present?)
        p "billable_hours .................................."
        p jtls_count.spent_hours / 3600.0
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
        p "non billable_hours .................................."
        p jtls_count.spent_hours / 3600
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
  def move_to_next_stage
    puts "coming to move_to_next_stage .............................."
    project_stage_id = self.project_stage_id
    jobs_stage_count = self.project_jobs.where(:project_stage_id=>project_stage_id).where("status not in ('Blocked')").count
    jobs_stage_completed_count = self.project_jobs.where(:project_stage_id=>project_stage_id).where("status in ('Resolved','Closed')").count
    if(jobs_stage_count == jobs_stage_completed_count)
      current_project_stage = self.project_stage
      next_project_stage = self.organization.project_stages.where("position > #{current_project_stage.position}").order("position asc").first
      if(next_project_stage.present?)
        self.project_stage_id = next_project_stage.id
        self.save
        puts "finally moved in move_to_next_stage ...>>>>>........>>>>>>..................."
      end
    end
    
  end
end

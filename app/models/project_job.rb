# == Schema Information
#
# Table name: project_jobs
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  assigned_to           :integer
#  created_by            :integer
#  priority              :string(255)
#  description           :text
#  start_date            :datetime
#  due_date              :datetime
#  estimate_hour         :integer
#  is_repeat             :boolean          default(FALSE)
#  notify_email_ids      :string(255)
#  status                :string(255)
#  project_job_type_id   :integer
#  project_job_group_id  :integer
#  individual_contact_id :integer
#  organization_id       :integer
#  project_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  is_completed          :boolean          default(FALSE)
#  resolved_at           :datetime
#  closed_at             :datetime
#  progress              :integer
#  job_no                :integer
#  catchup_later         :boolean          default(FALSE)
#  last_updated_by       :integer
#  is_archive            :boolean          default(FALSE)
#  is_accessible         :boolean          default(TRUE)
#  is_billable           :boolean
#  project_stage_id      :integer
#  estimate_minutes      :integer
#  contactable_type      :string(255)
#  contactable_id        :integer
#  event_source          :string(255)
#  event_id              :string(255)
#

class ProjectJob < ActiveRecord::Base
  include ProjectJobsHelper
  include AuthHelper
  belongs_to :project_job_type
  belongs_to :project_job_group
  belongs_to :individual_contact
  belongs_to :organization
  belongs_to :project
  belongs_to :project_stage
  belongs_to :contactable, polymorphic: true
  has_one :project_job_repeat, :dependent => :destroy
  has_many :job_time_logs, :dependent => :destroy
  has_many :resource_distributions, :dependent => :destroy
  belongs_to :assigned_user, :class_name=>"User", :foreign_key=>"assigned_to"
  has_many :in_app_notifications, :as => :notificationable, :dependent => :destroy
  attr_accessible :assigned_to, :created_by, :description, :due_date, :estimate_hour, :is_repeat, :name, :notify_email_ids, :priority, :start_date, :organization_id, :project_job_type_id, :project_job_group_id, :individual_contact_id, :project_id, :status, :created_at, :updated_at, :is_completed, :resolved_at, :close_at, :progress, :job_no, :catchup_later, :last_updated_by, :closed_at, :is_archive,:project_stage_id,:estimate_minutes,:is_client_included,:assigned_to_users,:is_schedule_appoint, :inspection_report_id, :inspection_report_type, :deal_id, :work_order_no, :is_started, :is_submitted, :is_accessible, :is_billable,:event_source,:event_id,:contactable_type,:contactable_id
  attr_accessor :assigned_to_users,:is_client_included,:due_date_start_time,:due_date_end_time,:is_schedule_appoint,:contactable_name_individual,:contactable_name_company,:project_type
  has_many :activities, :class_name=>"Activity", :dependent => :destroy,as: :source #,:foreign_key=>"source_id"
  acts_as_commentable
  scope :by_status, lambda{|status| where(status: status)}
  scope :completed_jobs, lambda{|completed| where(is_completed: completed)}
  scope :new_jobs, lambda{|status, completed| where(status: status, is_completed: completed)}
  scope :by_job_type, lambda{|job_type_id| where(project_job_type_id: job_type_id)}
  default_scope where(:is_archive => false, :is_accessible => true)
  scope :archived, -> { where(is_archive: true) }
  JOB_COLORS={"New"=>"#e3777d", "In Progress"=> "#659d36", "Resolved" => "#d56c4d", "Blocked" => "#e2b52d", "Closed" => "#999"}
  JOB_STATUSES=["New","In Progress","Resolved","Blocked","Closed"]
  before_create :set_default_data
  after_create :set_due_date
  after_save :change_progress_on_status_closed, :if => :status_changed?
  after_save :update_office365_calendar
  before_destroy :delete_office365_calendar
  def set_default_data
    self.job_no = self.project.project_jobs.present? ? self.project.project_jobs.last.job_no.to_i + 1 : 1
    # if self.project.project_jobs.count > 0
    #   self.update_attributes :job_no => self.project.project_jobs.last(2).first.job_no.to_i + 1
    # else
    #   self.update_attributes :job_no => 1
    # end
  end
  def set_due_date
    self.update_column(:due_date, self.due_date.nil? ? self.start_date : self.due_date)
  end
  def change_progress_on_status_closed
    if self.status == "Closed" && self.progress != 100
      self.update_attributes :progress => 100
    end
  end

  def user_responsible
  	self.organization.users.where("id=?",self.assigned_to).first
  end


  def self.job_list(project, job_type)
    query_condition=[]
    case job_type
    when "all"
      project_jobs = project.project_jobs
      order_by="due_date DESC"
    when "today"
      project_jobs = project.project_jobs.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
      p project_jobs.count
      order_by="due_date ASC"
    when "overdue"
      project_jobs = project.project_jobs.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
      order_by="due_date ASC"
    when "upcoming"
      project_jobs = project.project_jobs.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
      order_by="due_date ASC"
    when "completed"
      project_jobs = project.project_jobs.where("is_completed=?", true)
      order_by="due_date DESC"
    end
    project_jobs
  end
  def created_user
    self.organization.users.where("id=?",self.created_by).first
  end
  def assigned_user
    self.organization.users.where("id=?",self.assigned_to).first
  end

  def self.active_multi_filter(params)   
    query=""    
    if params[:cre_by] == true || params[:cre_by] == "true"
      if params[:cre_by_val].present? && (cre=params[:cre_by_val].split('|')).present? && (cre_ids=cre.join(','))
        query += "`project_jobs`.`created_by` IN (#{cre_ids})"
      end
    end
    if params[:asg_by] == true || params[:asg_by] == "true"
      query += " and "if query.present?
      if params[:asg_by_val].present? && (asg=params[:asg_by_val].split('|')).present? && (asg_ids=asg.join(','))#&& (asg_ids = asg.map{|a| a.to_i})
        query += "`project_jobs`.`assigned_to` IN (#{asg_ids})"
      end
    end

    if params[:proj] == true || params[:proj] == "true"
      query += " and "if query.present?
      if params[:proj_val].present? && (proj=params[:proj_val].split('|')).present? && (proj_ids=proj.join(','))
        query += "`project_jobs`.`project_id` IN (#{proj_ids})"
      end
      proj=true
    end
    puts "...................Project stage is coming in fitler"
    puts params[:proj_stage]
    if params[:proj_stage] == true || params[:proj_stage] == "true"
      query += " and "if query.present?
      if params[:proj_stage_val].present? && (proj_stage=params[:proj_stage_val].split('|')).present? && (proj_stage_ids=proj_stage.join(','))
        query += "`project_jobs`.`project_stage_id` IN (#{proj_stage_ids})"
      end
      proj_stage=true
    end

    if params[:priority] == true || params[:priority] == "true"
      query += " and "if query.present?
      if params[:priority_val].present? && (prio=params[:priority_val].split('|')).present? && (prio_vals=prio.map(&:inspect).join(','))
        query += "`project_jobs`.`priority` IN (#{prio_vals})"
      end
      prio = true
    end

    if params[:status] == true || params[:status] == "true"
      query += " and "if query.present?
      if params[:status_val].present? && (stat=params[:status_val].split('|')).present? && (stat_vals=stat.map(&:inspect).join(','))
        query += "`project_jobs`.`status` IN (#{stat_vals})"
      end
      prio = true
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
      query += "`project_jobs`.`created_at` BETWEEN '#{startdate}' AND '#{enddate}'"
    end
    
     if ((params[:dtrange_from] == true || params[:dtrange_from] == "true") && (params[:dtrange_to] == true || params[:dtrange_to] == "true"))
      query += " and "if query.present?
      frmdate = Date.parse(params[:dt_range_from]).strftime("%Y-%m-%d")
      todate = Date.parse(params[:dt_range_to]).strftime("%Y-%m-%d")
      query += "`project_jobs`.`created_at` BETWEEN '#{frmdate}' AND '#{todate}'"
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
     query += "`project_jobs`.`updated_at` < '#{last_d}'"
    end
    # if params[:status] == true || params[:status] == "true"
    #   query += " and "if query.present?
    #   if params[:status_val].present? && (status=params[:status_val].split('|')).present? && (statuses=status.join(','))
    #     query += "`project_jobs`.`status` IN (#{statuses})"
    #   end
    #   stage = true
    # end
    where(query).order("created_at desc")
  end

  def last_updated_user
    self.organization.users.where("id=?",self.last_updated_by).first
  end
  def logged_hours
    if(self.job_time_logs.present?)
      jtls_count = self.job_time_logs.select("sum(COALESCE(spent_hours,0)) as spent_hours").first
      if(jtls_count.present? && jtls_count.spent_hours.present?)
        return getHourMinuteFromSeconds(jtls_count.spent_hours)
      else
        return 0
      end
    else
      return 0
    end
  end
  def billable_hours
    if(self.job_time_logs.present?)
      jtls_count = self.job_time_logs.where(:is_billable=>true).select("sum(COALESCE(spent_hours,0)) as spent_hours").first
      if(jtls_count.present? && jtls_count.spent_hours.present?)
        return getHourMinuteFromSeconds(jtls_count.spent_hours)
      else
        return 0
      end
    else
      return "0"
    end
  end
  def nonbillable_hours
    if(self.job_time_logs.present?)
      jtls_count = self.job_time_logs.where(:is_billable=>false).select("sum(COALESCE(spent_hours,0)) as spent_hours").first
      if(jtls_count.present? && jtls_count.spent_hours.present?)
        return getHourMinuteFromSeconds(jtls_count.spent_hours)
      else
        return 0
      end
    else
      return "0"
    end
  end

  def self.get_project_jobs(organization_id,project_id,user_id,job_status, active_user_ids = [])
    project_jobs = ProjectJob.where(:organization_id=>organization_id)
    if(project_id != 'All')
      project_jobs = project_jobs.where(:project_id=>project_id)
    end
    if(user_id != 'All' && user_id != 0)
      project_jobs = project_jobs.where(:assigned_to=>user_id)
    else
      if active_user_ids.length > 0
        project_jobs = project_jobs.where("assigned_to IN (?)", active_user_ids)
      end
    end
    if(job_status.present?)
      project_jobs = project_jobs.where(status: job_status)
      if(job_status == 'Closed') || (job_status == 'Resolved')
        project_jobs = project_jobs.where('updated_at >=  ?',Date.today-7.days)
      end
    end
    return project_jobs.order("updated_at DESC")   
    
  end
  def self.check_project_jobs_exists(organization_id,project_id,user_id)
    project_jobs = ProjectJob.where(:organization_id=>organization_id)
    if(project_id != 'All')
      project_jobs = project_jobs.where(:project_id=>project_id)
    end
    if(user_id != 'All' && user_id != 0)
      project_jobs = project_jobs.where(:assigned_to=>user_id)
    end
    # project_jobs = project_jobs#.where('updated_at >=  ?',Date.today-7.days)
    return project_jobs.count
  end
  def self.get_project_jobs_stage_wise(organization_id,project_id,user_id,project_stage_id, active_user_ids = [])
    project_jobs = ProjectJob.where(:organization_id=>organization_id)
    if(project_id != 'All')
      project_jobs = project_jobs.where(:project_id=>project_id)
    end
    if(user_id != 'All' && user_id != 0)
      project_jobs = project_jobs.where(:assigned_to=>user_id)
    else
      if active_user_ids.length > 0
        project_jobs = project_jobs.where("assigned_to IN (?)", active_user_ids)
      end
    end
    if(project_stage_id.present?)
      project_jobs = project_jobs.where(project_stage_id: project_stage_id)
    end
    return project_jobs.order("updated_at DESC")   
    
  end
  def self.check_project_jobs_stage_wise_exists(organization_id,project_id,user_id,project_stage_id)
    project_jobs = ProjectJob.where(:organization_id=>organization_id)
    if(project_id != 'All')
      project_jobs = project_jobs.where(:project_id=>project_id)
    end
    if(user_id != 'All' && user_id != 0)
      project_jobs = project_jobs.where(:assigned_to=>user_id)
    end
    if(project_stage_id.present?)
      project_jobs = project_jobs.where(project_stage_id: project_stage_id)
    end
    # project_jobs = project_jobs#.where('updated_at >=  ?',Date.today-7.days)
    return project_jobs.count
  end
  def check_or_upgrade_project_stage
    ##check if all jobs under a project stage is completed?
    project_stage_id = self.project.project_stage_id
    if(project_stage_id == self.project_stage_id)
      self.project.move_to_next_stage
      # jobs_stage_count = self.project.project_jobs.where(:project_stage_id=>project_stage_id).where("status not in ('Blocked')").count
      # jobs_stage_completed_count = self.project.project_jobs.where(:project_stage_id=>project_stage_id).where("status in ('Resolved','Closed')").count
      # if(jobs_stage_count == jobs_stage_completed_count)
      #   self.project.move_to_next_stage
      # end
    end
  end
  def insert_in_google_calendar(caller,attendees)
    user = caller
    if user.token.present?
      @event = {
        'summary' => self.name,
        #'description' => self.description,
        'location' => 'Location',
        'start' => { 'dateTime' => Chronic.parse(Time.zone.at(self.due_date.to_i).strftime("%Y-%m-%d at %I:%M%P")) },
        'end' => { 'dateTime' => Chronic.parse(self.event_end_date.present? ? Time.zone.at(self.event_end_date.to_i).strftime("%Y-%m-%d at %I:%M%P") : Time.zone.at(self.due_date.to_i).strftime("%Y-%m-%d at %I:%M%P")) },
      }
      client = Google::APIClient.new(:application_name => 'InsetCRM',:application_version => '1.0.0')
      client.authorization.access_token = user.token
      service = client.discovered_api('calendar', 'v3')
      @set_event = client.execute(:api_method => service.events.insert,
            :parameters => {'calendarId' => user.email, 'sendNotifications' => true},
            :body => JSON.dump(@event),
            :headers => {'Content-Type' => 'application/json'})
    end
  end
  def insert_in_office365_calendar(caller,attendees,start_time,end_time,client)
    user = caller
    if user.present? && user.office_mail.present?
      
      @event = {
        "Subject": self.name,
        "Body": {
          "ContentType": "HTML",
          "Content": self.description
        },
        "Start": {
            "DateTime": Chronic.parse(Time.zone.at(start_time.to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
            "TimeZone": Time.zone
        },
        "End": {
            "DateTime": Chronic.parse(Time.zone.at(end_time.to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
            "TimeZone": Time.zone
        },
        "Attendees": [
          {
            "EmailAddress": {
              "Address": user.office_mail.office_mail,
              "Name": user.full_name.present? ? user.full_name : user.email
            },
            "Type": "Required"
          }
        ],
        "Extensions": {
            "@odata.type": "microsoft.graph.openTypeExtension",
            "extensionName": "Com.Contoso.Referral",
            "projectId": self.id
        },
      }

      attendees.each do |attendee|
        @event[:Attendees] << {
            "EmailAddress": {
              "Address": attendee.email,
              "Name": attendee.full_name.present? ? attendee.full_name : attendee.email
            },
            "Type": "Required"
          }
      end
      if(client.present?)
        @event[:Attendees] << {
            "EmailAddress": {
              "Address": client.email,
              "Name": client.full_name.present? ? client.full_name : client.email
            },
            "Type": "Required"
          }
      end
      event = add_event_to_office365_calendar(user,@event)
      self.event_source = 'Office365'
      self.event_id = event.id
      self.save
    end
  end
  def update_office365_calendar
    puts "originla id of projet_job type .............................."
    
    if(self.project_job_type.present? && self.project_job_type.original_id == 1 && self.event_source == 'Office365' && self.event_id.present?)
      attendees =  [self.assigned_user]
      start_time = self.start_date
      end_time = self.start_date + (self.estimate_minutes.present? ? self.estimate_minutes : 0).minutes

      if self.project.linked_with == "Opportunity" && self.project.lead.present? && self.project.lead.individual_contact.present?
        client = self.project.lead.individual_contact 
      elsif self.project.linked_with == "Contact"  && self.project.individual_contact.present?
        client = self.project.individual_contact
      elsif self.project.linked_with == "Organization"  && self.project.company_contact.present?
        client = self.project.company_contact
      end
      user = Thread.current[:user]
      if user.present? && user.office_mail.present?
        
        @event = {
          "Subject": self.name,
          "Body": {
            "ContentType": "HTML",
            "Content": self.description
          },
          "Start": {
              "DateTime": Chronic.parse(Time.zone.at(start_time.to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
              "TimeZone": Time.zone.now.strftime('%z')
          },
          "End": {
              "DateTime": Chronic.parse(Time.zone.at(end_time.to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
              "TimeZone": Time.zone.now.strftime('%z')
          },
          "Attendees": [
            {
              "EmailAddress": {
                "Address": user.office_mail.office_mail,
                "Name": user.full_name.present? ? user.full_name : user.email
              },
              "Type": "Required"
            }
          ]
          # ,
          # "Extensions": {
          #     "@odata.type": "microsoft.graph.openTypeExtension",
          #     "extensionName": "Com.Contoso.Referral",
          #     "projectId": self.id
          # },
        }

        attendees.each do |attendee|
          @event[:Attendees] << {
              "EmailAddress": {
                "Address": attendee.email,
                "Name": attendee.full_name.present? ? attendee.full_name : attendee.email
              },
              "Type": "Required"
            }
        end
        if(client.present?)
          @event[:Attendees] << {
              "EmailAddress": {
                "Address": client.email,
                "Name": client.full_name.present? ? client.full_name : client.email
              },
              "Type": "Required"
            }
        end
        event = update_event_to_office365_calendar(user,self.event_id,@event)
        
      end
    end
  end
  def delete_office365_calendar
    if(self.project_job_type.original_id == 1 && self.event_source == 'Office365' && self.event_id.present?)
    
      delete_event_from_office365_calendar(Thread.current[:user],self.event_id)
    end
  end
end

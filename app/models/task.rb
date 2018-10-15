# == Schema Information
#
# Table name: tasks
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  title           :string(255)
#  task_type_id    :integer
#  assigned_to     :integer
#  priority_id     :integer
#  deal_id         :integer
#  due_date        :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  mail_to         :string(255)
#  taskable_id     :integer
#  taskable_type   :string(255)
#  created_by      :integer
#  is_completed    :boolean          default(FALSE), not null
#  task_note       :text
#  recurring_type  :string(255)      default("none"), not null
#  rec_end_date    :datetime
#  parent_id       :integer
#  is_event        :boolean          default(FALSE), not null
#  event_end_date  :datetime
#  is_archive      :boolean          default(FALSE)
#  archive_by      :integer
#  is_accessible   :boolean          default(TRUE)
#  priority        :string(255)
#  status          :string(255)
#  details         :text
#  event_source    :string(255)
#  event_id        :string(255)
#

require 'csv'
require 'google/api_client'
require 'chronic'
class Task < ActiveRecord::Base
  include AuthHelper
  belongs_to :organization
  belongs_to :task_type
  belongs_to :taskable, :polymorphic => true
  belongs_to :initiator, :class_name=>"User",:foreign_key=>:created_by
  belongs_to :priority_type, :foreign_key => "priority_id" #,:class_name=>"TaskPriorityType"
  belongs_to :user, :foreign_key => "assigned_to"
  belongs_to :deal
  belongs_to :individual_contact
  belongs_to :company_contact
  has_one :reminder, :dependent => :destroy
  attr_accessible :assigned_to, :deal_id, :due_date,:organization_id,
                  :priority_id, :title, :task_type_id, :mail_to, :taskable_id, :taskable_type,
                  :is_completed, :task_note,:created_at,:created_by, :recurring_type, :rec_end_date,
                  :parent_id, :is_event, :event_end_date, :notify_email, :is_archive, :archive_by, :details, :priority, :status
  attr_accessor :notify_email


  #after_create :send_email,:inser_activity_table
  after_create :inser_activity_table,:insert_in_office365_calendar
  after_save :insert_update_activity,:update_latest_task_type, :insert_in_google_calendar,:update_office365_calendar
  before_destroy :delete_office365_calendar
  scope :by_is_completed, lambda {where("is_completed = ?", true)}
  scope :not_completed, lambda {where("is_completed = ?", false)}
  scope :in_prev_week, lambda{ where(:created_at => 1.week.ago.beginning_of_week..1.week.ago.end_of_week) }
  scope :in_current_week, lambda{ where(:created_at => Date.today.beginning_of_week..Date.today.end_of_week) }
  scope :by_range, lambda{ |start_date, end_date| where(:created_at => start_date..end_date) }
  scope :last_three_months, lambda{ where('tasks.updated_at >= ?', 3.months.ago)}  
  scope :by_name, lambda{ |name| includes(:task_type).where("task_types.name = ?", name) }
  default_scope where(:is_accessible => true)
  #include Tire::Model::Search
  #include Tire::Model::Callbacks
  
  ### Export CSV ###
  def self.to_csv
    CSV.generate do |csv|
      csv << ["Task Title", "Stage", "Created On", "Created By", "priority", "Visibilit••••••••y", "Next Action", "Contact Email", "Contact ID", "Contact Name"] ## Header values of CSV
      all.each do |task|
        deal = task.deal
        csv << [task.title, 
                deal.present? ? (deal.deal_status_name.present? ? deal.deal_status_name : "NA") : "NA",
                deal.present? ? deal.created_at : "NA",
                deal.present? ? deal.initiator_name : "NA",
                deal.present? ? (deal.priority_type.present? ? deal.priority_type.name : "NA") : "NA",
                deal.present? ? deal.is_public? ? "Public" : "Everyone" : "NA",
                deal.present? ? (deal.latest_task_type_id.present? ? deal.last_task.name : "No-Action") : "NA",
                deal.present? ? deal.contacts_email : "NA",
                deal.present? ? deal.contacts_id : "NA",
                deal.present? ? deal.contacts_name : "NA" ] ##Row values of CSV
      end
    end
  end

  def self.task_list(user, task_type, taskable=nil, limit=nil,task_type_info=nil,mytype=nil)
    #    task_log=Logger.new("log/task_list.log")
    #    user=User.find user if user.present?
    tasks=[]
      query_condition=[]
      org=user.organization if user.present?
      query_condition.where("tasks.organization_id=?", org.id) if user.present? && org.present?
      #    task_log.info "time now"
      #    task_log.debug Time.zone.now.strftime("%Y/%m/%d")
    if(taskable.nil?)
        #      task_log.info "taskable is nil"
        #      if tasks.present? 
        # if dashboard == true
        #          query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id)
        #        else !(user.is_admin? || user.is_super_admin?)
        #          query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id)
        #        end
	      #query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) #unless (user.is_admin? || user.is_super_admin?)
        #order_by="due_date DESC,priority_id"
        if mytype == "1"
         query_condition.where("(tasks.assigned_to=?)", user.id)
        end
        #order_by="due_date DESC"
        case task_type
          when "all"
            #order_by="due_date DESC"
          when "open"
            query_condition.where("is_completed=? ", false)
            #order_by="due_date DESC"
          when "today"
            # task_log.info "task type is today"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
            #order_by="due_date DESC"
          when "overdue"
            #  task_log.info "task type is overdue"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            #order_by="due_date DESC"
          when "upcoming"
            # task_log.info "task type is upcoming"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            #order_by="due_date ASC,priority_id"
            #order_by="due_date DESC"
          when "completed"
#            task_log.info "task type is completed"
            query_condition.where("is_completed=?", true)
            #order_by="updated_at DESC"
            #order_by="due_date DESC"
        end
        if task_type_info.present?
         query_condition.where("task_types.name=?",task_type_info)
        end
#      end
      tasks=includes(:initiator).includes(:user).includes(:task_type).includes(:priority_type).where(query_condition).limit(limit).order("due_date DESC")
    else    
      # tasks=taskable.tasks.order("due_date DESC,priority_id").limit(limit)
      # task_log.info "taskable is #{taskable.class.name}"
      # if tasks.present?
        if user.present?
          #query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) unless (user.is_admin? || user.is_super_admin?)
        end
         #order_by="tasks.due_date DESC,tasks.priority_id"
         #order_by="due_date DESC"
        case task_type
          when "today"
          # task_log.info "task type is today"
            query_condition.where("DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", Time.zone.now.strftime("%Y/%m/%d"))
            query_condition.where("is_completed=?", false) unless taskable.class.name == "Contact"
            #order_by="due_date DESC"
          when "overdue"
            # task_log.info "task type is overdue"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            #order_by="due_date DESC"
          when "upcoming"
            # task_log.info "task type is upcoming"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            #order_by="due_date DESC"
          when "completed"
            # task_log.info "task type is upcoming"
            query_condition.where("is_completed=?", true)
            #order_by="tasks.updated_at DESC"
            #order_by="due_date DESC"
        end
      # end
      tasks=taskable.tasks.includes(:taskable).includes(:initiator).includes(:user).includes(:task_type).includes(:priority_type).where(query_condition).limit(limit).order("due_date DESC")
    end
    tasks
  end
  
  def self.todays_task(user) 
    query_condition=[]
    	org=user.organization if user.present?
    	query_condition.where("tasks.organization_id=?", org.id) if user.present? && org.present?
    	query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) 
    	query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))	  
    	 order_by="due_date ASC"
    where(query_condition).order(order_by)

  end

  def self.task_list_dashboard(user, task_type, taskable=nil, limit=nil,task_type_info=nil)
    # task_log=Logger.new("log/task_list.log")
    # user=User.find user if user.present?
    tasks=[]
      query_condition=[]
      org=user.organization if user.present?
      query_condition.where("tasks.organization_id=?", org.id) if user.present? && org.present?
	  query_condition.where("(tasks.assigned_to=? OR tasks.created_by=?)", user.id, user.id) 

       #order_by="due_date DESC,priority_id"
       order_by="due_date ASC"
        case task_type
          when "today"
            # task_log.info "task type is today"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
            order_by="due_date ASC"
          when "overdue"
            # task_log.info "task type is overdue"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            order_by="due_date ASC"
          when "upcoming"
            # task_log.info "task type is upcoming"
            query_condition.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
            #order_by="due_date ASC,priority_id"
            order_by="due_date ASC"
          when "completed"
            # task_log.info "task type is completed"
            query_condition.where("is_completed=?", true)
            #order_by="updated_at DESC"
            order_by="due_date DESC"
        end
      if task_type_info.present?
         query_condition.where("task_types.name=?",task_type_info)
        end

      tasks=includes(:initiator).includes(:user).includes(:task_type).includes(:priority_type).where(query_condition).order(order_by).limit(limit)
   
  end
  
def update_latest_task_type
  if(d=self.deal).present? && self.is_completed == true 
     t_type =(t=d.tasks.where("is_completed=?",false).last).present? ? t.task_type_id : nil
     d.update_column(:latest_task_type_id,t_type)
  end
 end

def insert_in_google_calendar
  user = self.user
  if user.token.present?
    @event = {
      'summary' => self.title,
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
 
def insert_in_office365_calendar
  # user = self.user
  # begin
  #   if user.present? && user.office_mail.present?
  #     # @event = {
  #     #   'summary' => self.title,
  #     #   #'description' => self.description,
  #     #   'location' => 'Location',
  #     #   'start' => { 'dateTime' => Chronic.parse(Time.zone.at(self.due_date.to_i).strftime("%Y-%m-%d at %I:%M%P")) },
  #     #   'end' => { 'dateTime' => Chronic.parse(self.event_end_date.present? ? Time.zone.at(self.event_end_date.to_i).strftime("%Y-%m-%d at %I:%M%P") : Time.zone.at(self.due_date.to_i).strftime("%Y-%m-%d at %I:%M%P")) },
  #     # }
  #     @event = {
  #       "Subject": self.title,
  #       "Body": {
  #         "ContentType": "HTML",
  #         "Content": self.title
  #       },
  #       "Start": {
  #           "DateTime": Chronic.parse(Time.zone.at(self.due_date.to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
  #           "TimeZone": Time.zone
  #       },
  #       "End": {
  #           "DateTime": Chronic.parse(Time.zone.at((self.due_date + 30.minutes).to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
  #           "TimeZone": Time.zone
  #       },
  #       "Attendees": [
  #         {
  #           "EmailAddress": {
  #             "Address": user.office_mail.office_mail,
  #             "Name": user.full_name.present? ? user.full_name : user.email
  #           },
  #           "Type": "Required"
  #         }
  #       ]
  #     }
  #     event = add_event_to_office365_calendar(user,@event)
  #     self.event_source = 'Office365'
  #     self.event_id = event.id
  #     self.save
  #   end
  # rescue
  # end
end
def send_email
  #if (user.email_notification.nil?) || (user.email_notification && user.email_notification.task_assign == true && user.email_notification.donot_send == false)
    #Notification.send_task_info(user, initiator.full_name, self, self.taskable).deliver 
    #task_for_deal=false
    deal_contact_id=nil
    deal_title=""
    if(d=self.deal).present?
     d.update_column(:latest_task_type_id,self.task_type_id)
     deal_title=d.title
     #task_for_deal=true
     dc=d.deals_contacts.first
     contact=dc.contactable
     deal_contact_id=dc.id if dc.present?
    end
    email = user.email
    name = user.full_name
    formated_due_date = self.due_date.in_time_zone(user.time_zone).strftime("%a %d %b %Y @ %H:%M")
#    formated_event_end_date= self.event_end_date.in_time_zone(user.time_zone)
    event_start_date= self.due_date.in_time_zone(user.time_zone).to_i if self.due_date.present?
    event_end_date = self.event_end_date.in_time_zone(contact.time_zone).to_i if self.event_end_date.present?
    title = self.title
	  url = self.get_url
    type = self.taskable.class.name
    type_id = self.taskable.id
     puts "+++============================================="
    #p is_event
    p notify_email
    #p is_event || notify_email == "1"
    puts "+++============================================="
    #if is_event || notify_email == "1"
	if notify_email == "1"
     SendEmailNotification.perform_async(email,name,initiator.full_name,formated_due_date,title,url,type,type_id, is_event, event_start_date, event_end_date, deal_contact_id, deal_title, due_date)
    end

    
  #end
  end
  
  def inser_activity_table
    de_c = Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.created_by,:activity_type=> "Task", :activity_id => self.id, :activity_status => "Create",:activity_desc=>self.get_title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.deal_id,:source_type => self.deal.class.name)
    de_a = Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.assigned_to,:activity_type=> "Task", :activity_id => self.id, :activity_status => "Assign",:activity_desc=>self.get_title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.deal_id,:source_type => self.deal.class.name)
    ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> de_a.id,:contactable_type=>self.taskable_type,:contactable_id=> self.taskable_id)
    ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> de_c.id,:contactable_type=>self.taskable_type,:contactable_id=> self.taskable_id)
    # dl = Deal.find self.deal_id
    # dl.update_column :last_activity_date,  de_a.activity_date  
  end
  
  def insert_update_activity
    unless self.created_at == self.updated_at
      a1=Activity.create(:organization_id => self.organization_id,	:activity_user_id => self.created_by,:activity_type=> "Task", :activity_id => self.id, :activity_status => self.is_completed? ? "Complete" : "Update",:activity_desc=>self.get_title,:activity_date => Time.zone.now, :is_public => true, :source_id => self.deal_id,:source_type => self.deal.class.name)
      ActivitiesContact.create(:organization_id => self.organization_id, :activity_id=> a1.id,:contactable_type=>self.taskable_type,:contactable_id=> self.taskable_id)
    end
  end
  
  def get_title
    # (self.taskable ? self.taskable.title : "" ) + " / " + self.title
    self.title.truncate(35)
  end

  def get_title_hover
    # (self.taskable ? (self.taskable.title.truncate(15) )  : "" ) + " / " + (self.title.truncate(12))
    self.title
  end

  def get_opportunity_title
    self.taskable ? self.taskable.title : ''
  end

  def outcome
    self.task_note
  end
  def get_url
    if self.taskable.present?
      self.taskable.class.name == "Deal" ? "/leads/"+ self.taskable.to_param.to_s : (self.taskable.class.name == "CompanyContact" ? "/company_contact/"+ self.taskable.to_param.to_s : "/contact/"+ self.taskable.to_param.to_s)
    end
  end
  def get_contact_name
    if self.taskable.present?
      if self.taskable.class.name == "Deal"
        self.deal.present? && self.deal.deals_contacts.present? && self.deal.deals_contacts.first.contactable.present? && self.deal.deals_contacts.first.contactable.full_name.present? ? self.deal.deals_contacts.first.contactable.full_name : ""
      elsif self.taskable.class.name == "IndividualContact"
        self.taskable.full_name
      end
    end
  end
  def get_contact_url
    if self.taskable.present?
      if self.taskable.class.name == "Deal"
        self.deal.present? && self.deal.deals_contacts.present? && self.deal.deals_contacts.first.contactable.present? && self.deal.deals_contacts.first.contactable.full_name.present? ? "/contact/"+self.deal.deals_contacts.first.contactable.to_param : ""
      elsif self.taskable.class.name == "IndividualContact"
        "/contact/"+self.taskable.to_param
      end
    end
  end
  # mapping do
  #    indexes :image_url
  #    indexes :initiator_name
  #    indexes :assigned_user_name
  #    indexes :taskable_title
  #    indexes :taskable_name
  #    indexes :taskable_id
  #  end
  
  def to_indexed_json
    to_json( 
      #:only   => [ :id, :name, :normalized_name, :url ],
      :methods   => [:image_url, :initiator_name, :assigned_user_name, :taskable_title, :taskable_name, :taskable_id]
    )
  end
  
  def image_url
    #if initiator.image.present?
    #  initiator.image.image.url(:icon)
    #else
    #  "/assets/no_user.png"
    #end
    "#{ENV['cloudfront']}/assets/tasks_small.png"
  end
  
  
  def initiator_name
    initiator.present? ? initiator.full_name : "None"
  end
  
  def assigned_user_name
    user.present? && user.full_name.present? ? user.full_name : (user && user.email.present? ? user.email.split("@")[0] : "Not Available")
  end
  def assigned_user_first_name
    user.present? ? user.first_name : "Not Available"
  end
  
  def taskable_title
    taskable.present? ? taskable.title : ""
  end  
  
  def taskable_name
    taskable.present? ? taskable_type : ""
  end
  
  
  def taskable_id
    taskable.present? ? taskable.id : ""
  end
  
   def self.active_multi_filter_report(params)
    
    if(params[:q] == "1")
      start_date = DateTime.new(params[:y].to_i,1,1)
      end_date = DateTime.new(params[:y].to_i,3,31)     
    elsif(params[:q] == "2")
      start_date = DateTime.new(params[:y].to_i,4,1)
      end_date = DateTime.new(params[:y].to_i,6,30)     
    elsif(params[:q] == "3")
      start_date = DateTime.new(params[:y].to_i,7,1)
      end_date = DateTime.new(params[:y].to_i,9,30)     
    elsif(params[:q] == "4")
     start_date = DateTime.new(params[:y].to_i,10,1)
     end_date = DateTime.new(params[:y].to_i,12,31)     
    end
    query=""
     if params[:assigned_to] != "" && (start_date.present? && end_date.present?)
      #query += " and "if query.present?
      query += "tasks.assigned_to=#{params[:assigned_to]}"
      
      query += " and " if query.present?      
      
      query += "`tasks`.`created_at` BETWEEN '#{start_date}' AND '#{end_date}'"
      
     else
       query += "tasks.assigned_to=#{params[:assigned_to]}"
     
      
    end
    
    
    
    
    
    where(query)
   end
  
  def self.active_multi_filter_usage_summery(params) 
      query=""
      if params[:t_type] != ""
           query += "tasks.task_type_id=#{params[:t_type]}"
      end
      
      if params[:assigned_to] != ""
      query += " and "if query.present?
      query += "tasks.assigned_to=#{params[:assigned_to]}"
     end
    
      where(query).last_three_months
  end

  def self.active_multi_filter(params)
    # deal_type: params[:deal_type], asg_to: params[:asg_to], task_type: params[:task_type] , task_status: params[:task_status
    query=""
    d_type=false
    if params[:deal_type].present? && params[:deal_type] != ""
      d_type=true
      query += "deals.deal_status_id=#{params[:deal_type]}"
    end
    if params[:asg_to].present? && params[:asg_to] != "" && 
      asg_to = params[:asg_to].split(',')
      unless asg_to[0].include?('All')
        query += " and "if query.present?
        query += "tasks.assigned_to IN (#{asg_to.join(',')})"
      end
    end
    if params[:task_type].present? && params[:task_type] != ""
      query += " and "if query.present?
      query += "tasks.task_type_id=#{params[:task_type]}"
    end
    if params[:dt_range].present? && params[:dt_range] != "" && !params[:dt_range].blank?
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
      end
      query += " and " if query.present?      
      
      query += "`tasks`.`created_at` BETWEEN '#{startdate}' AND '#{enddate}'"
    end
    
    if d_type
     joins(:deal).where(query)
    else
     where(query)
    end
  end
  
  def belongs_to_category
      today_date = Time.zone.now.strftime("%Y/%m/%d")
      due_date = self.due_date.strftime("%Y/%m/%d")
      if  due_date == today_date
        "today"
      #p self.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))  
      elsif due_date < today_date
         "overdue"
      elsif due_date > today_date
         "upcoming"     
      end
  end

  def linked_with
    task_linked_with = ""
    type = self.taskable_type
    if type == "Deal"
      task_linked_with = "Opportunity"
    elsif type == "IndividualContact"
      task_linked_with = "Lead/Contact"
    elsif type == "CompanyContact"
      task_linked_with = "Organization"
    else
      task_linked_with = ""
    end
    task_linked_with
  end

  def update_office365_calendar
    # if(self.task_type.original_id == 1 && self.event_source == 'Office365')
    #   user = self.user
    #   begin
    #     if user.present? && user.office_mail.present?
      
    #       @event = {
    #         "Subject": self.title,
    #         "Body": {
    #           "ContentType": "HTML",
    #           "Content": self.title
    #         },
    #         "Start": {
    #             "DateTime": Chronic.parse(Time.zone.at(self.due_date.to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
    #             "TimeZone": Time.zone
    #         },
    #         "End": {
    #             "DateTime": Chronic.parse(Time.zone.at((self.due_date + 30.minutes).to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
    #             "TimeZone": Time.zone
    #         },
    #         "Attendees": [
    #           {
    #             "EmailAddress": {
    #               "Address": user.office_mail.office_mail,
    #               "Name": user.full_name.present? ? user.full_name : user.email
    #             },
    #             "Type": "Required"
    #           }
    #         ]
    #       }
    #       event = update_event_to_office365_calendar(user,self.event_id,@event)
          
    #     end
    #   rescue
    #   end
    # end
  end
  def delete_office365_calendar
    if(self.task_type.original_id == 1 && self.event_source == 'Office365' && self.event_id.present?)
    
      delete_event_from_office365_calendar(Thread.current[:user],self.event_id)
    end
  end
  
end


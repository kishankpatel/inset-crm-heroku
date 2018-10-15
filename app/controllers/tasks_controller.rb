require 'csv'
class TasksController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@parkpointsoftware.com.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/
  skip_before_filter :authenticate_user!, :only => [:send_task_reminder_notification]
  before_filter :retrieve_tasks, :only => [:complete, :start_task, :all_task, :today_task, :overdue_task, :upcoming_task, :calendar_data, :task_filter]
 cache_sweeper :cache_sweeper
  
 def index
    task_id=nil
    user_id=nil
    if params[:stask_id].present? && params[:suser].present?
      task_id = params[:stask_id]
      user_id = params[:suser]
    elsif session[:task_id].present? && session[:task_user].present?
      task_id = session[:task_id]
      user_id = session[:task_user]
    end
    @task = Task.where("id = ?", task_id).first
    @user = User.where("id = ?", user_id).first
    if @task.present? && @user.present?
      @task.insert_in_google_calendar
      [:non_authenticate, :task_id, :suser, :task_user].each { |k| session.delete(k) }
    end
    if request.format.csv?
      @tasks = @current_organization.tasks.order("created_at desc")
    end
    #@title = "Task Listing | Task Management Software | InSet CRM"
    @description = "InSet CRM task management tool, user task listing page. User can view, assign and customize all his task in this page."
    respond_to do |format|
      format.html
      format.json { render json: TasksDatatable.new(view_context) }
      format.csv { send_data @tasks.to_csv, :filename => 'export-tasks-' + Time.zone.now.strftime("%Y%m%d%I%M%S").to_s + '.csv' }
    end
  end

  def create
    Time.zone = current_user.time_zone if current_user && current_user.time_zone
    taskable=nil
    error_msg=""
    # if(params[:taskable_type] == 'Project')
        
    #     project_id = params[:taskable_id]
    #     p params[:taskable_type]
    #     params[:taskable_type] = 'IndividualContact'
    #     params[:taskable_id] = params[:taskable_contact_id]
    #   end
    taskable_type = params[:taskable_type]
    respond_to do |format|
     begin
        #if params[:task][:deal_id].present? || params[:taskable_id].present?
          if params[:taskable_type] == "Opportunity" || params[:taskable_type] == "Deal"
            if params[:taskable_id].present?
              #@channel="/messages/deals#{params[:task][:deal_id]}"
             taskable=Deal.find(params[:taskable_id])
            else
             #p error_msg="Deal doesn't exist."
            end
            
          elsif params[:taskable_type] == "CompanyContact" || params[:taskable_type] == "IndividualContact"
            if params[:taskable_id].present?
              taskable= eval(taskable_type).find(params[:taskable_id])
            else
              error_msg="Contact doesn't exist."
            end
          end
          if error_msg.blank?
  #          if params[:task][:recurring_type] == "none"
  #          p task=Task.new(params[:task])
  #          task.organization=current_user.organization
  #          task.taskable=taskable
  #          task.created_by = current_user.id
              if save_task(params, taskable)
               
                # if(project_id.present?)

                #   project = Project.where(:id=>project_id).first
                #   if(project.present?)
                #     project_params = Hash.new
                #     project_params[:project_job] = Hash.new
                #     project_params[:project_job][:start_date] = params[:task][:due_date].to_date.strftime('%m/%d/%Y')
                #     project_params[:project_job][:due_date] = params[:task][:due_date].to_date.strftime('%m/%d/%Y')
                #     project_params[:project_job][:name] = params[:task][:title]
                #     project_params[:project_job][:project_id] =project_id 
                #     project_params[:project_job][:assigned_to] = @current_user.id
                #     project_params[:project_job][:priority]="Low"
                #     project_params[:project_job][:created_by]=@current_user.id
                #     project_params[:project_job][:organization_id]=@current_organization.id
                #     project_params[:project_job][:status]="New"
                #     project_params[:project_job][:project_job_type_id] = ""
                #     project_params[:project_job][:project_stage_id] = project.project_stage_id
                #     project_params[:project_job][:last_updated_by] = @current_user.id
                #     prj_ctrl = ProjectJobsController.new
                #     prj_ctrl.create_job(project_params)
                #   end
                # end
                # #for pub-sub
                # task= {
                     # created_at: task.created_at.strftime("%I:%M %p"),
                     # created_date: task.created_at.strftime("%y%m%d"),
                     # title: task.get_title,
                     # created_id: task.created_by,
                     # created_by: task.initiator_name == current_user.full_name ? "me" : task.initiator_name,
                     # assigned_id: task.assigned_to,
                     # assigned_name: task.assigned_user_first_name == current_user.full_name ? "me" : task.assigned_user_first_name ,
                     # due_date: task.due_date.strftime("%a %d %b %Y @ %H:%M")
                  # }
                  
                # PrivatePub.publish_to(@channel, :chat_message => task, :type => "task")
                #end pub-sub
                flash[:bosuccess]="Awesome! A new task has been added. Keep them coming!"
                
                # check Email Notify is checked or not While creating a task.
                # if params[:task][:notify_email].to_i == 1 && is_valid_user_email
                #   # After task has been saved successfully send a email to assigned user.
                #   Notification.send_assigned_email_notification( @current_organization.users.find(@task.assigned_to), @task, @current_organization.users.find(@task.created_by)  ).deliver
                # end
                session[:task_id] = @task.id
                session[:task_user] = current_user.gmail_related_id.present? ? current_user.gmail_related_id : current_user.id
                task_info={status: true, msg: "Task has been saved successfully.", ttype: @task.task_type.present? ? @task.task_type.name : "None", date: @task.due_date.strftime("%a %d %b %Y @ %H:%M"), tdate: task_tab(@task)}
                
                Analytics.track(
                user_id: current_user.id,
                event: 'Create Task',
                properties: { task_title: @task.title,
                              first_name: current_user.first_name,
                              last_name: current_user.last_name,
                              email: current_user.email
                            })
                @task.insert_in_office365_calendar if @task.task_type.original_id  == 1
                format.json { render :json => task_info }
              else
                  alert_msg=""
                  if error_msg ==""
                    msgs=@task.errors.messages
                    msgs.keys.each_with_index do |m,i|
                      alert_msg=m.to_s.camelcase+" "+msgs[m].first
                      alert_msg += "<br />" if i > 0
                    end
                  else
                    alert_msg=error_msg
                  end
                 p alert_msg
                 task_info = {status: false, msg: alert_msg.to_s}
             #redirect_to request.referer 
                format.json { render json: task_info }
      #          format.js {render text: alert_msg.to_s}
              end
            else
              task_info = {status: false, msg: error_msg}
              format.json { render json: task_info }
            end
        # else
        #   if params[:taskable_type] == "Deal" && !params[:task][:deal_id].present?
        #     error_msg="Selected deal doesn't exist." 
        #   else
        #     error_msg="Selected contact doesn't exist."
        #   end
        #   p task_info = {status: false, msg: error_msg}
        #   format.js {render text: task_info}
        # end

         rescue => e
            p task_info = {status: false, msg: "ERROR 500: Sorry something went wrong!"}
             format.js {render text: task_info}
         end
    end
  end
  

  def save_task(params, taskable)
     if(params[:task][:is_event].present? && params[:task][:is_event].to_i == 1)
       all_task_types = current_user.organization.task_types
       meeting_type = all_task_types.where(:name => "Meeting").first
       params[:task][:task_type_id] = meeting_type.id if meeting_type.present?
     end
     @task=Task.new(params[:task])
     @task.organization=current_user.organization
     @task.taskable=taskable
     @task_date = params[:task][:due_date].split(" ")[0]
     @task_due = "#{@task_date} #{params[:due_time]}"
     p @task_due
     @task.created_by = current_user.id
     @task.due_date = @task_due
     if @task.save
       if params[:set_is_reminder].present? && params[:reminder_datetime].present?
          Reminder.create(:task_id => @task.id, :user_id => @task.assigned_to, :is_reminder => true, :reminder_datetime => params[:reminder_datetime])
       end
       @task.update_column(:parent_id, @task.id)
       if params[:task][:recurring_type] == "none"
         return true
       else
          start_date=@task.due_date
          if @task.reminder.present? && @task.reminder.reminder_datetime.present?
            reminder_date=@task.reminder.reminder_datetime
          end
          end_date=@task.rec_end_date if @task.rec_end_date
          if end_date.present?
            while(start_date < end_date)
              case @task.recurring_type
              when "daily"
  #             if start_date.strftime("%^a") == "FRI"
  #               add_date = 3.day
  #             elsif start_date.strftime("%^a") == "SAT"
  #               add_date = 2.day
  #             else
                  add_date =1.day
  #             end
              when "weekly"
                add_date= 1.week
              when "monthly"
                add_date= 1.month
              when "qtr"
                add_date=3.months
              when "yearly"
                add_date=1.year
              else
                
              end
              new_task=@task.dup
              start_date+=add_date
              if reminder_date.present?
                reminder_date+=add_date
              end
              new_task.due_date=start_date
              new_task.parent_id=@task.id              
              if new_task.save
                if reminder_date.present?
                  Reminder.create(:task_id => new_task.id, :user_id => new_task.assigned_to, :is_reminder => true, :reminder_datetime => reminder_date)
                end
              end
            end
          end
         return true
       end
     else
      return false
     end
  end
  
  def task_tab(task)
      tab_name="all"
      if task.due_date.to_date > Date.today
        tab_name="upcoming"
      elsif task.due_date.to_date == Date.today
        tab_name="today"
      elsif task.due_date.to_date < Date.today
        tab_name="overdue"
      end
      tab_name
  end
  def show_task_detail
    @task = Task.find(params[:task_id])
    render partial: "task_details", status: :ok
  end
  
  def follow_up_task
    @follow = Task.find(params[:task_id])
    if params[:taskable_type].present? && params[:taskable_id].present?
      @taskable_type = params[:taskable_type]
      @taskable_id = params[:taskable_id].to_i
    end
    render partial: "task_follow_form", :content_type => 'text/html'
  end
  
  def edit_task
    @task = Task.find(params[:task_id])
    render partial: "task_form", :content_type => 'text/html'
  end
  
  def update
    task=Task.where("id=?",params[:id]).first
    respond_to do |format|
      if params[:taskable_type].present? && params[:taskable_id].present?
        taskable_obj= eval(params[:taskable_type]).where("id=?", params[:taskable_id]).first
        task.taskable = taskable_obj
        task.deal_id = params[:taskable_id] if params[:taskable_type] == "Deal"
      end
      
      if task.update_attributes(params[:task])
       if params[:reminder_datetime].present?
          if task.reminder.present?
            task.reminder.update_attributes(:user_id => task.assigned_to, :is_reminder => params[:set_is_reminder].present? ? true : false, :reminder_datetime => params[:reminder_datetime])
          else
            Reminder.create(:task_id => task.id, :user_id => task.assigned_to, :is_reminder => params[:set_is_reminder].present? ? true : false, :reminder_datetime => params[:reminder_datetime])
          end
       end
        Analytics.track(
          user_id: current_user.id,
          event: 'Update Task',
          properties: { first_name: current_user.first_name,
                        last_name: current_user.last_name,
                        email: current_user.email,
                        task_title: task.title
                      })
        assigned_user=User.where("id=?",task.assigned_to).first          
        task_info={status: true, msg: "Task has been updated successfully.", id: task.id, title: task.title, assigned_user: assigned_user.present? ? assigned_user.full_name : "", ttype: task.task_type.present? ? task.task_type.name : "None", date: task.due_date.strftime("%a %d %b %Y @ %H:%M"), due_date: task.due_date.strftime("%b %d, %Y"), tdate: task_tab(task)}
        format.json { render :json => task_info }
      else
          alert_msg=""
          if error_msg ==""
            msgs=task.errors.messages
            msgs.keys.each_with_index do |m,i|
              alert_msg=m.to_s.camelcase+" "+msgs[m].first
              alert_msg += "<br />" if i > 0
            end
          else
            alert_msg=error_msg
          end
         task_info = {status: false, msg: alert_msg.to_s}
        format.json { render json: task_info }
      end
    end
  end
  
  def complete
    task = Task.find(params[:task_id])
    @comp_task_type=params[:task_type]

    #if(params[:create_task] == 1 || params[:create_task] == "1")
     t_note = ""
     tt = ""
     if params[:task_out_val].present?
      params[:task_out_val].chop.split(',').each do |f|
        task_ot_cm = @current_organization.task_outcomes.find(f)
        t_note += task_ot_cm.name + ","

       if(params[:create_task] == 1 || params[:create_task] == "1")
        if task_ot_cm.task_out_type.present?
         #task_ty_o = task_ot_cm.task_out_type.split(',')
         task_ty = TaskType.where("organization_id = ? and name = ?",@current_organization.id,task_ot_cm.task_out_type).first 
           if(task_ot_cm.task_duration == "1 Day")

             due = Time.now + 1.day
           elsif(task_ot_cm.task_duration == "2 Day")
             due = Time.now + 2.day
           elsif(task_ot_cm.task_duration == "1 Week")
             due = Time.now + 1.week
           elsif(task_ot_cm.task_duration == "2 Week")
             due = Time.now + 2.week
           elsif(task_ot_cm.task_duration == "1 Month")

             due = Time.now + 1.month
           end
          task_ty_id = task_ty.present? ? task_ty.id : @current_organization.task_types.where("name=?","None").first.id
        else
          due = task.due_date
          task_ty_id = task.task_type.present? ? task.task_type.id : ""
        end
        Task.create(:organization_id=>@current_organization.id,:title=>task.title,:task_type_id=>task.task_type_id,:assigned_to=>task.assigned_to,:priority_id=>task.priority_id,:deal_id=>task.deal_id,:due_date=>task.due_date,:mail_to=>task.mail_to,:taskable_id=>task.taskable_id,:taskable_type=>task.taskable_type,:created_by=>@current_user.id,:task_note=>task_ot_cm.name,:parent_id=>task.parent_id)
      end
    end
   end
    if params[:task_out_val].chop == "8" || params[:task_out_val].chop == 8

     task_note = params[:note]
    elsif params[:task_out_val].present?
    #elsif !t_note.present?
     task_note = t_note.chop
    else
      task_note = task.task_note
    end
    if(params[:create_task] == "0" && params[:stype]=="task")
      if(task.update_attributes(:task_note => task_note))
        # render partial: "task_header", :content_type => 'text/html'
        render text: ERB::Util.html_escape(params[:task_type])
      else
        flash[:notice]="Plz try again"
      end
    elsif(params[:create_task] == "1" && params[:stype]=="task")
      # render partial: "task_header", :content_type => 'text/html'
      render text: ERB::Util.html_escape(params[:task_type])
    elsif(params[:complete_task].present? && params[:complete_task] == "true" )
      task.update_attributes(:is_completed => true)
      render partial: "task_header", :content_type => 'text/html'
    else  
      if task.update_attributes(:task_note => task_note)
        if(params[:stype]=="task")
          case params[:task_type]
          when "today"
            @tasks=@tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d')=? ", false, Time.zone.now.utc_offset, Time.zone.now.strftime("%Y/%m/%d"))
          when "overdue"
            @tasks=@tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') < ?", false, Time.zone.now.utc_offset, Time.zone.now.strftime("%Y/%m/%d"))
          when "upcoming"
            @tasks=@tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') > ?", false, Time.zone.now.utc_offset, Time.zone.now.strftime("%Y/%m/%d"))
          end
          render partial: "task_header", :content_type => 'text/html'
        elsif (params[:stype]=="deal")
          @deal = Deal.find(params[:deal_id])
          @tasks = @deal.tasks
          render partial: "deals/widget_task_header", :content_type => 'text/html'
        elsif (params[:stype]=="dashboard")
          @tasks=@tasks.where("is_completed=? AND DATE_FORMAT(due_date, '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
          render partial: "home/widget_task_header", :content_type => 'text/html'
        elsif (params[:stype]=="contact")
          get_contact_tasks(params[:contact_id])
          @for_contact=true
         render partial: "contacts/task_widget", :content_type => 'text/html'
        end
      else
        flash[:notice]="Plz try again"
      end
    end
  end
  
  def start_task
    task = Task.find(params[:task_id])
    @comp_task_type=params[:task_type]
    if task.update_attributes(:is_completed => false, :task_note => nil)
      if(params[:stype]=="task")
        render partial: "task_header", :content_type => 'text/html'
      elsif (params[:stype]=="contact")
        get_contact_tasks(params[:contact_id])
       render partial: "contacts/task_widget", :content_type => 'text/html'
      elsif (params[:stype]=="deal")
        @deal = Deal.find(params[:deal_id])
        @tasks = @deal.tasks
        render partial: "deals/widget_task_header", :content_type => 'text/html'
      end
    else
      flash[:notice]="Plz try again"
    end
  end
  
  def get_contact_tasks(contact_id)
     @contact=current_user.organization.contacts.where("id=?", contact_id).first
     @today_tasks=Task.task_list(nil,"today",@contact)
     @overdue_tasks=Task.task_list(nil,"overdue",@contact)
     @upcoming_tasks=Task.task_list(nil,"upcoming",@contact)
     @completed_tasks=Task.task_list(nil,"all",@contact).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') <> ? ", true, Time.zone.now.utc_offset, Time.zone.now.strftime("%Y/%m/%d"))
  end
  
  def task_listing
   unless params[:task_status] == "calendar"
     # @tasks=Task.task_list(current_user, params[:task_type])
     partial_file= "task_list"
   else
     partial_file = "calendar_view"
   end
    render partial: partial_file
  end
  
  def task_filter
    @task_types=params[:ids]
    # @tasks=@tasks.includes(:task_type).where("is_completed=? AND task_types.id IN (?)", false, params[:ids])
    if params[:cal] 
      render partial: "calendar_view"
    else
      render partial: "task_list", :content_type => 'text/html'
    end
  end
  def delete_task_modal
    @task = Task.where("id=?",params[:id]).first
    if @task.present?
      render :partial => "delete_task_modal"
    end
  end
  def destroy
    task = Task.find(params[:id])
    deal = task.deal
    if params[:delete_all_recurring] == "true"
      if task.recurring_type != "none"
        tasks=@current_organization.tasks.where("parent_id=? And due_date >= ?", task.parent_id, task.due_date)
        tasks.destroy_all
      else
        task.destroy
      end
    else
      task.destroy
    end
    # if params[:delete_all_task] == "true"
    #   tasks=Task.where("parent_id=? And is_completed = false", task.parent_id)
    #   tasks.destroy_all
    # else
    #   task.destroy
    # end 
    t_type = deal.present? && deal.last_task.present? ? deal.last_task.name : "No-Action"
    respond_to do |format|
      flash[:notice]="Task(s) has been deleted successfully."
      format.html { redirect_to request.referer }
      format.json { render json: t_type.to_json, head: :no_content}
      format.js { render text: "success" }
    end
  end
  
  def calendar_data
    if request.xhr?
      events = []
      start_date,end_date="",""
      start_date =Time.zone.at(params[:start].to_i).strftime("%Y/%m/%d") if params[:start].present?
      end_date =Time.zone.at(params[:end].to_i).strftime("%Y/%m/%d") if params[:end].present?
     
      if (params[:deal_type] != "" ||  params[:asg_to] != "" || params[:task_type] != "")
        @tasks = @tasks.active_multi_filter(params)
      end
      #@tasks=@tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') BETWEEN ? AND ?", false, start_date, end_date )
      # if params[:filter_type].present? && params[:filter_type] == "all"
        @tasks=@tasks.where("DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') BETWEEN ? AND ?", Time.zone.now.utc_offset, start_date, end_date)
      # else
      #     @tasks=@tasks.where("DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') BETWEEN ? AND ? and (DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') = ? or DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?)",start_date, end_date, Time.zone.now.strftime("%Y/%m/%d"),Time.zone.now.strftime("%Y/%m/%d") )
      # end
      @tasks.each do |task|
        deal = task.taskable
        if task && deal
          task.due_date= task.created_at unless task.due_date.present?
          if  task.user && task.user.image && task.user.image.present?
           imgurl = task.user.image.image(:icon)
          else
           imgurl = "/assets/no_user.png"
          end
          deal_status_name = ""
          class_name = deal.class.name
          if class_name == "Deal"
            class_name = "Lead"
            deal_status_name = deal.deal_status_name
          elsif class_name == "IndividualContact"
            class_name = "Contact"
          else
            class_name = "Organization"
          end
          status = task.status.present? ? task.status : ""
            
          events << {:linked_to => class_name, :class_name => class_name, :id => task.id, :img=>imgurl, :is_complete=> task.is_completed, :tasktype=> task.task_type.present? ? task.task_type.name : "None" , :assign_to=> "#{(task.user.present? ? (task.user.full_name.present? ? task.user.full_name : task.user.email) : 'NA')}", :url=> "javascript:void(0)", :title => task.title ,:lead_info => deal.title, :className=>"test",  :color=> "#ddd", :description => "At - #{task.due_date.strftime('%I:%M %p')}\nTask - "+task.title+"\n Deal - " + deal.title+"\nAssigned To - "+(task.user ? task.user.full_name : ""), :start => "#{task.due_date.iso8601}", :end => "#{task.due_date.iso8601}", :allDay => false, :start_date => task.due_date.strftime('%d %b, %Y'), :start_time => task.due_date.strftime('%I:%M%p'), :lead_url => "http://#{request.host_with_port}/leads/#{deal.to_param}", :details => task.details, :deal_status => deal_status_name, :status => status}
        end
      end
    end
    # http://#{request.host_with_port}/leads/#{deal.to_param}
    # ,   :color=> TaskType::TASK_COLORS[task.task_type.present? ? task.task_type.name : "None"]
    respond_to do |format|
      format.json { render json: events}
    end
  end
  
  
  def get_sqllite_task
  tasks = []
  @tasks = Task.todays_task(current_user)
  @tasks.each do |tsk|
  tasks <<
  {
    title: tsk.get_title ,
    duedate: tsk.due_date,
    created_by: tsk.initiator_name,
    assigned_to: tsk.assigned_user_first_name,
    deal_id: tsk.deal_id,
    tasktype: tsk.task_type.present? ? tsk.task_type.name : "None",
    is_complete: 0,
    is_notified: 0
  }
  end
  respond_to do |format|
      format.json { render json: tasks}
    end
  end
  
  def task_tab_data
    render partial: "task_tab_data"
  end
  def get_task_details
    @task = Task.find(params[:id])
    render :partial => "show"
  end
  def fetch_tasks
    where = build_where_clause
    if @current_user.is_admin?  
      tasks = @current_organization.tasks
    else
      tasks = @current_organization.tasks.where(where).where("(created_by=? OR assigned_to=? )", @current_user.id, @current_user.id)
    end
    case params[:task_type]
    when "today"
      if @current_user.is_admin?
        @tasks=tasks.where(where).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
      else
        @tasks=tasks.where(where).where("( created_by=? OR assigned_to=? ) AND is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", @current_user.id, @current_user.id ,false, Time.zone.now.strftime("%Y/%m/%d"))
      end
    when "overdue"
      if @current_user.is_admin?  
        @tasks=tasks.where(where).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
      else
        @tasks=tasks.where(where).where("( created_by=? OR assigned_to=? ) AND is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", @current_user.id, @current_user.id, false, Time.zone.now.strftime("%Y/%m/%d"))
      end
    when "upcoming"
      if @current_user.is_admin?
        @tasks=tasks.where(where).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
      else
        @tasks=tasks.where(where).where("( created_by=? OR assigned_to=? ) AND is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", @current_user.id, @current_user.id, false, Time.zone.now.strftime("%Y/%m/%d"))
      end
    else
      if @current_user.is_admin?
        @tasks=tasks.where(where)
      else
        @tasks=tasks.where(where).where("( created_by=? OR assigned_to=? ) AND is_completed=?", @current_user.id, @current_user.id, false)
      end
    end
    @tasks=@tasks.order("created_at desc").limit(10)
    render partial: "home/tasks_list"
  end
  def build_where_clause
    where = ''
    where += ' AND ' unless where.empty?
    
    if(params[:filter_type] == "thisquarter" || params[:filter_type] == "lastquarter" ) 
      @curr_quarter =  get_month_quarter Date.today
      if params[:filter_type] == "thisquarter"
        @current_quarter = @curr_quarter
      else
        @current_quarter = @curr_quarter - 1
      end
      if(@current_quarter == 1)
        @start_date = DateTime.new(Time.zone.now.year,1,1)
        @end_date = DateTime.new(Time.zone.now.year,3,31)
      elsif(@current_quarter == 2)
        @start_date = DateTime.new(Time.zone.now.year,4,1)
        @end_date = DateTime.new(Time.zone.now.year,6,30)
      elsif(@current_quarter == 3)
        @start_date = DateTime.new(Time.zone.now.year,7,1)
        @end_date = DateTime.new(Time.zone.now.year,9,30)
      elsif(@current_quarter == 4)
        @start_date = DateTime.new(Time.zone.now.year,10,1)
        @end_date = DateTime.new(Time.zone.now.year,12,31)
      elsif(@current_quarter == 0)
        @start_date = DateTime.new(Time.zone.now.year - 1,10,1)
        @end_date = DateTime.new(Time.zone.now.year - 1,12,31)
      end
    end

    case params[:filter_type]
    when "thisweek"
      where += "#{where.present? ? 'and' : ''} (tasks.created_at >= '#{Time.zone.now-1.week}' and tasks.created_at <= '#{Time.zone.now}')"
    when "lastweek"
      where += "#{where.present? ? 'and' : ''} (tasks.created_at >= '#{1.week.ago.beginning_of_week}' and tasks.created_at <= '#{1.week.ago.end_of_week}')"
    when "thismonth"
      where += "#{where.present? ? 'and' : ''} (tasks.created_at >= '#{Time.zone.now.beginning_of_month}' and tasks.created_at <= '#{Time.zone.now.end_of_month}')"
    when "lastmonth"
      where += "#{where.present? ? 'and' : ''} (tasks.created_at >= '#{1.month.ago.beginning_of_month}' and tasks.created_at <= '#{1.month.ago.end_of_month}')"
    when "thisquarter"
      where += "#{where.present? ? 'and' : ''} (tasks.created_at >= '#{@start_date}' and tasks.created_at <= '#{@end_date}')"
    when "lastquarter"
      where += "#{where.present? ? 'and' : ''} (tasks.created_at >= '#{@start_date}' and tasks.created_at <= '#{@start_date}')"
    when "thisyear"
      where += "#{where.present? ? 'and' : ''} (tasks.created_at >= '#{Time.zone.now-1.year}' and tasks.created_at <= '#{Time.zone.now}')"      
    when "lastyear"
      where += "#{where.present? ? 'and' : ''} (tasks.created_at >= '#{1.year.ago.beginning_of_year}' and tasks.created_at <= '#{1.year.ago.end_of_year}')"
    end
    if params[:filter_user_id] == 'All'
      where
    else
      where += "#{where.present? ? 'and' : ''} (tasks.created_by = '#{params[:filter_user_id]}' OR tasks.assigned_to = '#{params[:filter_user_id]}')"
    end
  end
  def get_task_type
    @task_types = @current_organization.task_types
    render partial: "get_task_type"
  end
  def change_task_type
    @task = @current_organization.tasks.find(params[:task_id])
    old_task_type = @task.task_type.present? ? @task.task_type.name : "None"
    @task.update_attributes(task_type_id: params[:task_type_id])
    render text: ERB::Util.html_escape(old_task_type)
  end
  def send_task_reminder_notification
    @task_reminder_logger = Logger.new('log/task_reminder.log')
    task_reminders = Reminder.where(is_reminder:true , is_reminder_sent: false)
    if task_reminders.present?
      begin
        puts "++++++++++++++++ Total Task reminder #{task_reminders.count}+++++++++++++"
        task_reminders.each do |task_reminder|
          puts "++++++++++++++++ Task reminder +++++++++++++"
          @task_reminder_logger.info "========= Total Task reminder #{task_reminders.count} ========="
          assigned_user=task_reminder.user
          if assigned_user.present?
            created_user=task_reminder.task.organization.users.find_by_id(task_reminder.task.created_by)
            assigned_user_timezone = assigned_user.time_zone.present? ? assigned_user.time_zone : "Kolkata"
            reminder_time = task_reminder.reminder_datetime.in_time_zone(assigned_user_timezone)
            @task_reminder_logger.info "------------------- task reminder datetime"
            @task_reminder_logger.info reminder_time
            @task_reminder_logger.info "------------------- current datetime"
            @task_reminder_logger.info (Time.now + 5.minutes).in_time_zone(assigned_user_timezone)
            if (Time.now).in_time_zone(assigned_user_timezone) < reminder_time && ((Time.now + 5.minutes).in_time_zone(assigned_user_timezone) > reminder_time )
              Notification.send_task_reminder_notification(assigned_user, task_reminder, created_user).deliver
              task_reminder.update_column :is_reminder_sent, true
              @task_reminder_logger.info "----------- successfully sent reminder notification #{assigned_user.email}"
            end
          end
        end
      rescue
      end
      @task_reminder_logger.info "----------- Task reminder notification completed."
      render :text => "Task reminder notification completed."
    else
      @task_reminder_logger.info "----------- Reminder not available"
      render :text => "Reminder not available"
    end
  end
  def update_google_task_sync
    if params[:type] == "never"
      @current_user.update_column(:disable_google_task_sync, true)
    else
      @current_user.update_column(:google_task_sync_display_at, Time.now)
    end
    render :text => "success"
  end
private
  def retrieve_tasks
    query_condition=[]
    if @current_user.is_admin? || @current_user.is_super_admin?
      #query_condition.where("organization_id=?", @current_organization.id)
    query_condition.where("tasks.organization_id=?", @current_organization.id)

    else
      #query_condition.where("organization_id=? AND (tasks.assigned_to=? OR tasks.created_by=?)", @current_organization.id, @current_user.id, @current_user.id)
    query_condition.where("tasks.organization_id=? AND (tasks.assigned_to=? OR tasks.created_by=?)", @current_organization.id, @current_user.id, @current_user.id)

    end
    @tasks=Task.includes(:task_type, :user, :taskable).where(query_condition).order("due_date DESC,priority_id")
  end
end

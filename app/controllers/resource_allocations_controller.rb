
class ResourceAllocationsController < ApplicationController
# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@parkpointsoftware.com.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/
  include ApplicationHelper
  # include ResourcesDatatable
  def index
    get_durations("current_month")
    # @resource_distributions = ResourceDistribution.resource_allocations @start_date.to_datetime.in_time_zone(@current_user.time_zone),@end_date.to_datetime.in_time_zone(@current_user.time_zone)
    
  end
  def resource_utilization
    
    respond_to do |format|
      format.html
      format.json { render json: ::ResourcesDatatable.new(view_context)  }  
    end
  end
  def get_resource_utilization
    render :partial=>"resource_utilization_list"
  end
  def get_resource_allocation
    user= User.where(:id=>params[:user_id]).first
    start_date = params[:start_date]
    end_date = params[:end_date]
    type = params[:type]
    allot_type = params[:allot_type].present? ? params[:allot_type] : "weekly"
    view_for=params[:view_for]
    p "before call ................"
    # p params[:allot_type]
    # p params[:view_for]
    type = get_view_for_type(view_for,allot_type)
    # p type
    if(type.present?)
      get_durations(type)
    end
    # p @start_date
    # p @end_date
    project_id = params[:project_id].present? ? params[:project_id].to_i : 0
    
    if(user.present?)
      puts "user  present ............................"

      resource_distributions = ResourceDistribution.resource_allocations @start_date.to_date,@end_date.to_date,user.id
      render :partial=>'get_resource_allocation',:locals=>{resource_distributions: resource_distributions,:start_date=>@start_date,:end_date=>@end_date}
    else
      puts "user not present ---------------------------"
      #resource_distributions = ResourceDistribution.resource_allocations @start_date.to_datetime.in_time_zone(@current_user.time_zone),@end_date.to_datetime.in_time_zone(@current_user.time_zone),0,0,project_id
   
      render :partial=>'get_all_user_allocation',:locals=>{ :start_date=>@start_date.to_date,:end_date=>@end_date.to_date,project_id: project_id}
    end
    
  end
  def weekly_timesheet
    get_values_weekly_timesheet('current_week')
  end
  def get_values_weekly_timesheet(view_for)
    get_durations(view_for)
    # archived_projects =  @current_organization.projects.archived.map(&:id)
    
    if params[:user_id].present?
      @user = User.where(:id=>params[:user_id]).first
    else
      @user = @current_user
    end    
    @timesheet = JobTimeLog.get_timesheet(@user,@start_date.to_datetime.in_time_zone(@user.time_zone),@end_date.to_datetime.in_time_zone(@user.time_zone))
    p @timesheet.map{|ts| ts.log_start_time}
    log_project_job_ids = @timesheet.map(&:project_job_id)
    
    if !log_project_job_ids.present?
      log_project_job_ids = []
    end
    project_jobs_query = ProjectJob.where(:organization_id=>@current_user.organization_id,:assigned_to=>@user.id).where("((updated_at between ? and ? ) or (created_at between ? and ? ) or (?  between start_date and due_date ) or (? between start_date and due_date )) or (id in (?)) ", @start_date,@end_date, @start_date,@end_date, @start_date,@end_date,log_project_job_ids)
    # if archived_projects.present?
    #   @project_jobs = project_jobs_query.where("project_id not in (?)",archived_projects).all
    # else
      
       @project_jobs = project_jobs_query.all
       
    # end
  end
  def get_weekly_timesheet
    view_for = params[:view_for]
    type = get_view_for_type(view_for,'weekly')
    
    get_values_weekly_timesheet(type)
    
    render :partial=>'get_weekly_timesheet',:locals=>{user:@user,timesheet: @timesheet,:start_date=>@start_date,:end_date=>@end_date,project_jobs: @project_jobs}
    
  end
  def weekly_timesheet_save
    user_id = params[:user_id]
    spent_timesheet = params[:spent_time]
    spent_timesheet.each do |pj| 
      project_job = ProjectJob.where(:id=>pj[0]).first
      days = pj[1]
      days.each do |day_value|        
        dv_data = (day_value[1].to_h)
 
        if( dv_data["spent_hours"] != "0" && dv_data["spent_hours"] != "")
          date =  Time.at( day_value[0].to_i)
          date = DateTime.strptime( date.strftime("%m/%d/%Y %H:%M%p") + " " + Time.zone.now.strftime('%z'),"%m/%d/%Y %H:%M%p %z" )
          
          hours = dv_data["spent_hours"].split(":")
          hours_in_secs = (hours[0].to_i )*60*60
          hours_in_secs += (hours[1].to_i) *60
          
          is_billable = dv_data["is_billable"].present? ? (dv_data["is_billable"] == "1" ? true : false) : false
          
          jtl=JobTimeLog.where(user_id: user_id,project_job_id:project_job.id,log_start_time: date, log_end_time: date).where("log_start_time = log_end_time").first
          p jtl
          if (!jtl.present? && hours_in_secs > 0)
            jtl = JobTimeLog.new(organization_id: @current_user.organization_id, user_id: user_id,project_job_id:project_job.id,log_start_time: date, log_end_time: date, spent_hours: hours_in_secs,break_time: 0,is_billable:is_billable,note: "")
          elsif(jtl.present?)
            jtl.spent_hours= hours_in_secs
            jtl.is_billable=is_billable
          end
          jtl.save if !jtl.nil?
            
          
        end

      end
    end
    # return :action=>get_weekly_timesheet
    render :json=>{status: "success",:message=>"Timesheet saved successfully!"}
  end
  def get_resource_for_reallocation
    user= User.where(:id=>params[:user_id]).first
     puts "timezone of current_user"
      p @current_user.time_zone
    project_job = ProjectJob.where(:id=>params[:project_job_id]).first
    if(!params[:user].present?)
      user = project_job.assigned_user
    end
    view_for=params[:view_for]
    if(view_for == 'all')
      puts "timezone of current_user"
      p @current_user.time_zone
      @start_date = project_job.start_date.present? ? project_job.start_date : project_job.created_at
      @end_date = project_job.due_date
    else
      type = get_view_for_type(view_for,allot_type)
      if(type.present?)
        get_durations(type)
      end
    end
    user_ids = project_job.job_time_logs.map(&:user_id).uniq
    p user_ids
    if user_ids.present? && user.present?
      user_ids.push(user.id)
    else
      user_ids = [user.id]
    end
    users = User.where("id in (?)",user_ids).all
    p @start_date
    p @end_date
    if(users.count == 1 && @start_date.present?  && @end_date.present?)
      puts "users count ======================== 0"
       resource_distributions = ResourceDistribution.resource_allocations @start_date.in_time_zone(@current_user.time_zone), @end_date.in_time_zone(@current_user.time_zone), user.id, project_job.id
       
       render :partial=>'reallocate_resource',:locals=>{project_job: project_job,resource_distributions: resource_distributions,:start_date=>@start_date,:end_date=>@end_date,:assigned_user=>user,:users=>users}
    else
      dt_start = (jtl = project_job.job_time_logs.order("log_start_time asc").select("job_time_logs.log_start_time").first).present? ? jtl.log_start_time.to_time : @start_date
      
      @start_date = (dt_start > @start_date ? @start_date : dt_start) 
      dt_end = (jtl = project_job.job_time_logs.order("log_start_time asc").select("job_time_logs.log_start_time").first).present? ? jtl.log_start_time.to_time : @end_date
      @end_date = (dt_end < @end_date ? @end_date  : dt_end) if(dt_end.present?)
      if(@start_date.present?  && @end_date.present?)
      puts "now coming to get resource distribution ..................................."
      puts @start_date.in_time_zone(@current_user.time_zone)
      puts @end_date.in_time_zone(@current_user.time_zone)
      puts "-----------------------------"
      
        resource_distributions = ResourceDistribution.resource_allocations @start_date.to_date, @end_date.to_date, users.count == 1 ? user.id : 0, project_job.id
        render :partial=>'reallocate_resource',:locals=>{project_job: project_job,resource_distributions: resource_distributions,:start_date=>@start_date,:end_date=>@end_date,:assigned_user=>user,:users=>users}
      else
        render :text=>"Job Start date and end date not set"
      end
    end
    # else
    #   resource_distributions = ResourceDistribution.resource_allocations @start_date,@end_date
    #   render :partial=>'reallocate_resource',:locals=>{resource_distributions: resource_distributions,:start_date=>@start_date,:end_date=>@end_date}
    # end
  end
  def reallocate_resource

    project_job = ProjectJob.where(:id=>params[:project_job_id]).first
    user_id = params[:user_id]
    allocated_hours = params[:allocated]
    allocated_hours.each do |day_value| 
      # p day_value[0]
      vday = Time.at( day_value[0].to_i).to_date
      dv_data = day_value[1]["value"]
      hours = dv_data.split(":")
      hours_in_mins = (hours[0].to_i )*60
      hours_in_mins += (hours[1].to_i) 
      
      p hours_in_mins
      rd = ResourceDistribution.where(:project_job_id=> project_job.id,:allotted_date => vday, :user_id => user_id).first
      if(rd.present?)
        puts "coming to update......."
        puts rd.allotted_time
        puts hours_in_mins
        rd.update_attributes({
          :allotted_time => hours_in_mins, 
          :allotted_date => vday
          })
      elsif(!rd.present? && hours_in_mins != 0)
        puts "coming to create new ...................."

        rd = ResourceDistribution.create({
        :organization_id=>@current_user.organization_id,
        :project_id=> project_job.project_id,
        :project_job_id=> project_job.id,
        :user_id => project_job.assigned_to,
        :allotted_time => hours_in_mins, 
        :allotted_date => vday
        })
      end
    end
    render :json=>{status: "success",:message=>"Resource Allocated successfully!"}
  end
  private
  def get_view_for_type(view_for,allot_type)
    p "get_view_for_type......................"
    p view_for
    p allot_type
    if(view_for == 'current')
      case allot_type
        when 'weekly'
          type = 'current_week'
        when 'monthly'
          type = 'current_month'
        when 'next_thirty'
          type = 'current_next_thirty'
      end
    elsif (view_for == 'next')
      case allot_type
        when 'weekly'
          type = 'custom_next_week'
        when 'monthly'
          type = 'custom_next_month'
        when 'next_thirty'
          type = 'custom_next_thirty'
         
      end
    elsif (view_for == 'prev')
      case allot_type
        when 'weekly'
          type = 'custom_prev_week'
        when 'monthly'
          type = 'custom_prev_month'
        when 'next_thirty'
          type = 'custom_prev_thirty'
      end
    else
      type = view_for
    end

    return type

  end
end

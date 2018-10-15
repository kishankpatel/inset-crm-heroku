
class CalendarController < ApplicationController

  require 'google/api_client'
  include AuthHelper
  include EmailHelper
  def index
    #get_all_calendar_data
  end
  def get_all_calendar_data
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    p params
    events = []
    @start_date,@end_date="",""
    @start_date =Time.zone.at(params[:start].to_i).strftime("%Y/%m/%d") if params[:start].present?
    @end_date =Time.zone.at(params[:end].to_i).strftime("%Y/%m/%d") if params[:end].present?
    events_json = []
    #########         Office365            #################
    if current_user.office_mail.present? && params[:office_source] == "true"
      begin
        if !(@start_date.present? && @end_date.present?)
          get_durations('current_week')
        end
        
        @events = get_calendar_events(current_user, @start_date,@end_date ) 
        events_json = []
        @events.map{|event| {title: event.subject,start:event.start.date_time , end: event.end.date_time}}
        @events.each do |event|
          puts "................................................."
          project_job = @current_organization.project_jobs.where(:event_source =>'Office365',:event_id=> event.id).first
          task = @current_organization.tasks.where(:event_source =>'Office365',:event_id=> event.id).first
          if(project_job.present?)
           events_json << {color: '#62cb31',textColor: "#fff",title: event.subject,start:event.start.date_time, end: event.end.date_time,linked_to: 'ProjectJob', info: project_job.project.name,assign_to: project_job.assigned_user.full_name,status: project_job.status,stage:project_job.project_stage.name,details: project_project_job_path(project_job.project.id,project_job.id),project_job_id: project_job.id.to_s,id: event.id ,event_source:'Office365',organizer: event.organizer}
          elsif task.present?
            
            events_json << {color: '#e74c3c',textColor: "#fff",title: event.subject,start:event.start.date_time, end: event.end.date_time,linked_to: 'Task', info: task.taskable.present? ? task.taskable.title : '',assign_to: task.user.full_name,status: task.status,stage:task.is_completed? ? "Completed" : "Open",details: "view_popup('#{task.id}')",task_id: task.id,id: event.id,event_source:'Office365' ,organizer: event.organizer}
          else
            events_json << {color: '#428bca',textColor: "#fff",title: event.subject,start:event.start.date_time, end: event.end.date_time,id: event.id,event_source:'Office365',linked_to: '',organizer: event.organizer}
          end
        end
       
      rescue RuntimeError => e
        @errors = [
          {
            message: 'Microsoft Graph returned an error getting events.',
            debug: e
          }
        ]
        render :json=>@errors
        
        
      end
    end
    #########         Gmail               #################
    if current_user.email_account.present? && params[:google_source] == "true"
      # begin
        puts "current user's access tken.................................."
        # if(current_user.token.present?)
        # end
        if !(@start_date.present? && @end_date.present?)
          get_durations('current_week')
        end
        
        if(current_user.email_account.access_token_expired?)
          current_user.email_account.refresh_access_token!
        end
        items = get_google_calendar_events(current_user, @start_date,@end_date ) 
        # client = Google::APIClient.new(:application_name => 'InsetCRM',:application_version => '1.0.0')
        # client.authorization.access_token = current_user.email_account.fresh_token
        # service = client.discovered_api('calendar', 'v3')
        # result = client.execute(:api_method => service.events.list,
        #   :parameters => {'calendarId' => current_user.email,timeMin: @start_date.to_datetime.rfc3339, timeMax: @end_date.to_datetime.rfc3339  },
          
        #   :headers => {'Content-Type' => 'application/json'})
        # items = result.data.items
        
        #items.map{|event| events_json <<  {color: '#ffb606',textColor: "#fff",title: event.summary,start:event.start.present? ? event.start.dateTime : nil, end: event.end.present? ? event.end.dateTime : nil,id: event.id,event_source:'Google',linked_to: '',organizer: event.organizer}}
        items.each do |event|
          
          if(event.status != 'cancelled' && event.summary.present?)
            p event
            puts "................................................."
            project_job = @current_organization.project_jobs.where(:event_source =>'Google',:event_id=> event.id).first
            task = @current_organization.tasks.where(:event_source =>'Google',:event_id=> event.id).first
            sdate  = event.start.present? && event.start.date.present? ? event.start.date : event.start.present? && event.start.dateTime.present? ? event.start.dateTime : nil
            edate  = event.end.present? && event.end.date.present? ? event.end.date : event.end.present? && event.end.dateTime.present? ? event.end.dateTime : nil
            if(project_job.present?)
             events_json << {color: '#62cb31',textColor: "#fff",title: event.summary,start: sdate, end: edate,linked_to: 'ProjectJob', info: project_job.project.name,assign_to: project_job.assigned_user.full_name,status: project_job.status,stage:project_job.project_stage.name,details: project_project_job_path(project_job.project.id,project_job.id),project_job_id: project_job.id.to_s,id: event.id ,event_source:'Google',organizer: event.organizer.self == true ? true : false} 
            elsif task.present?
              
              events_json << {color: '#e74c3c',textColor: "#fff",title: event.summary,start:sdate, end: edate,linked_to: 'Task', info: task.taskable.present? ? task.taskable.title : '',assign_to: task.user.full_name,status: task.status,stage:task.is_completed? ? "Completed" : "Open",details: "view_popup('#{task.id}')",task_id: task.id,id: event.id,event_source:'Google' ,organizer: event.organizer.self == true ? true : false}
            else
           
              events_json << {color: '#110066',textColor: "#fff",title: event.summary,start:sdate, end: edate,id: event.id,event_source:'Google',linked_to: '',organizer: event.organizer.self == true ? true : false}
            end
          end
        end
      # rescue => ex
      #   p ex.message
      # end
    end
    render json: events_json
  end
  def edit_calendar_event
    Time.zone = current_user.time_zone if current_user && current_user.time_zone
    @zone_time = Time.zone.now
    event_id = params[:event_id]
    event_title = params[:event_name]
    organizer = params[:organizer]
    start_time = DateTime.strptime(params[:event_start] + " " + @zone_time.strftime('%z'), "%m/%d/%Y %H:%M %z" )
    end_time = DateTime.strptime(params[:event_end] + " " + @zone_time.strftime('%z'), "%m/%d/%Y %H:%M %z" )
    if(params[:event_source] == 'Office365')
      
      request_params ={
          "Subject": event_title ,
          "Start": {
            "DateTime": Chronic.parse(Time.zone.at(start_time.to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
            "TimeZone": Time.zone.now.strftime('%z')
          },
          "End": {
              "DateTime": Chronic.parse(Time.zone.at(end_time.to_i).strftime("%Y-%m-%d at %I:%M%P")) ,
              "TimeZone": Time.zone.now.strftime('%z')
          }
      }
      update_event_to_office365_calendar(current_user,event_id,request_params)
    elsif (params[:event_source] == 'Google')
      p organizer
      p current_user.email_account.email
      
      
        request_params = {
        'summary' => event_title,
        #'description' => self.description,
        'start' => { 'dateTime' => Chronic.parse(Time.zone.at(start_time.to_i).strftime("%Y-%m-%d at %I:%M%P")) },
        'end' => { 'dateTime' => Chronic.parse(Time.zone.at(end_time.to_i).strftime("%Y-%m-%d at %I:%M%P")) },
        }
        response = update_event_to_google_calendar(current_user,event_id,request_params)
        p response.status
      if(response.status != 200)
        render json: {status: "error",message: "Only organizer can edit calendar event"}
        return
      end
    end
    
    render json: {status: "success"}
  end
  def delete_calendar_event
    event_id = params[:event_id]
    if(params[:event_source] == 'Office365')
      delete_event_from_office365_calendar(current_user,event_id)
    elsif(params[:event_source] == 'Google')
      response = delete_event_from_google_calendar(current_user,event_id)
      p response.status
      if(response.status != 200) && (response.status != 204)
        render json: {status: "error",message: "Only organizer can edit calendar event"}
        return
      end
    end
    render json: {status: "success"}
  end

  private
  def client_options
  {
    client_id: SECRET_CONFIG[:google_client_id],
    client_secret: SECRET_CONFIG[:google_client_secret],
    authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
    token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
    scope:   'https://www.googleapis.com/auth/calendar',
    redirect_uri: "#{root_url}/auth/google/mailbox/callback"
  }
  end
end

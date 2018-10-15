class ProjectJobsController < ApplicationController
  before_filter :set_project_job, only: [:show, :edit, :update, :destroy, :fetch_job_content,:get_project_job]
  
  # Job listing page
  def index
    @project = @current_organization.projects.find_by_id(params[:project_id])
    begin
      @remaining_projects = @current_organization.projects.where("id != ?", @project.id)
    rescue
      flash[:warning] = "Project not found."
      redirect_to "/projects" and return
    end
    #cookies[:project_id] = params[:project_id]
    respond_to do |format|
      format.html
      format.json { render json: ProjectJobsDatatable.new(view_context) }
    end
  end
  def kanban
    if(params[:project_id].present?)
      @project = @current_organization.projects.find_by_id(params[:project_id])
      begin
        @remaining_projects = @current_organization.projects.where("id != ?", @project.id)
      rescue
        flash[:warning] = "Project not found."
        redirect_to "/projects" and return
      end
      if !params[:user_id].present?
        params[:user_id] = 'All'
      end
      render :action=>'index',:params=>{:type=>'project_specific'}
    else
      params[:project_id] = 'All'
      if !params[:user_id].present?
        params[:user_id] = 'All'
      end
      render :action=>'all_user_kanban',:params=>{:type=>'all_user'}
    end
  end
  def all_user_kanban
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    p params
    # params[:user_id] = 'All'
  end
  # Job details page
  def show
    user_job_notification = @current_user.in_app_notifications.where("notificationable_id = ?", @project_job.id).first
    if user_job_notification.present?
      user_job_notification.update_column :is_read, true
    end
    @comment = @project_job.comments.new
  end
  def get_project_job
    render :partial =>'edit_project_job_popup_detail'
  end
  # New job page
  def new
  	@project = Project.find_by_id(params[:project_id])
    @project_job = ProjectJob.new
  end

  def edit
    @project = Project.find_by_id(params[:project_id])
  end

  # Job creation
  def create
    Time.zone = current_user.time_zone if current_user && current_user.time_zone
    #   # begin
    # Time.zone = current_user.time_zone if current_user && current_user.time_zone
    # @zone_time = Time.zone.now
    # s_date =DateTime.strptime(params[:project_job][:start_date] + " " + @zone_time.strftime('%z'), "%m/%d/%Y %z" ) if params[:project_job][:start_date].present?
    # e_date = DateTime.strptime(params[:project_job][:due_date] + " " + @zone_time.strftime('%z'), "%m/%d/%Y %z" ) if params[:project_job][:due_date].present?
    #    #.in_time_zone(@current_user.time_zone)
    # params[:project_job][:start_date] = s_date 
    # params[:project_job][:due_date] = e_date 
    # minutes = params[:project_job][:estimate_hour].present? ? get_minutes_from_input_value( params[:project_job][:estimate_hour]) : 0
    #   # params[:project_job][:start_date] = Date.strptime(params[:project_job][:start_date], "%m/%d/%Y" )if params[:project_job][:start_date].present?
    #   # params[:project_job][:due_date] = Date.strptime(params[:project_job][:due_date], "%m/%d/%Y") if params[:project_job][:due_date].present?
    #   user_ids = params[:project_job][:notify_email_ids].split(",") if params[:project_job][:notify_email_ids].present?
    #   params[:project_job] = params[:project_job].merge(:last_updated_by=>@current_user.id)
      
    #   @project_job = ProjectJob.new(params[:project_job])

    #   # if params[:project_job][:start_date].present?
    #   #   @project_job.start_date = Date.strptime(params[:project_job][:start_date], "%m/%d/%Y")
    #   # end
    #   # if params[:project_job][:due_date].present?
    #   #   @project_job.due_date = Date.strptime(params[:project_job][:due_date], "%m/%d/%Y")
    #   # end
    #   @project_job.project_id=params[:project_id] if params[:project_id].present?
    #   @project_job.project_stage_id = @project_job.project.project_stage_id
    #   @project_job.estimate_minutes = minutes
    #   if params[:project_job][:is_repeat] == "true"
    #   	params[:project_job_repeat][:repeat_start] = DateTime.strptime(params[:project_job_repeat][:repeat_start], "%m/%d/%Y")
    #     params[:project_job_repeat][:repeat_end_on] = DateTime.strptime(params[:project_job_repeat][:repeat_end_on], "%m/%d/%Y") if params[:project_job][:repeat_end_on].present?
    #     @project_job_repeat = @project_job.build_project_job_repeat(params[:project_job_repeat])
    #   end
       
    #   # Send email to checked users
    #   if @project_job.save
    #     #p @project_job.estimate_hour.present? && @project_job.start_date.present? && @project_job.due_date.present?
    #     # begin
    #       #if(@project_job.estimate_hour.present? && @project_job.start_date.present? && @project_job.due_date.present?)
    #       if(@project_job.estimate_minutes.present? && @project_job.start_date.present? && @project_job.due_date.present?)
    #           distribute_hours_for_user(@project_job,@project_job.start_date)
    #       end
          
    #     # rescue Exception => e

    #     # end
    #     create_in_app_notification("Create", "Created project job '#{@project_job.name}'")
    #     Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @project_job.created_by, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "Create", :activity_desc => @project_job.name, :activity_date => @project_job.created_at, :is_public => true, :source_id => @project_job.id)
    #     begin
    #       # if params[:create_type] == "quick"
    #       #   @project_job.project.project_users.create(:user_id => @current_user.id)
    #       # end
    #       users_mail = @current_organization.users.where("id IN (?)",user_ids).collect(&:email).join(",")
    #       Notification.send_assigned_job_notification(users_mail, @project_job, @current_user).deliver if is_valid_user_email
    #     rescue Exception => e
          
    #     end
    #   end
    if(create_job(params))
      if params[:submit_type] == "save" || params[:quick].present?
        flash[:notice] = "Your new job has been created successfully."
        respond_to do |format|
          format.html {redirect_to project_project_jobs_path(@project_job.project)}
          format.json { render :json => {
              status: "success",
              message:  "Your new job has been created successfully."
            }}
          format.js {render :js=>"showStatusAfterJobCreate('success','" + "Your new job has been created successfully." + "','#{@project_job.project_id}','#{params[:project_id].to_i}')"}
        end
        #redirect_to project_project_jobs_path(@project_job.project)
        
      else
        redirect_to new_project_project_job_path(@project_job.project)
      end
    else
      redirect_to new_project_project_job_path(@project_job.project)
    end
      # rescue => ex
      #   p ex.message
      # end
    
  end
  def create_job(params)
    ProjectJob.transaction do
      is_schedule_appoint = params[:project_job][:is_schedule_appoint].present? && params[:project_job][:is_schedule_appoint] == "true" ? true : false

      @zone_time = Time.zone.now
      s_date =DateTime.strptime(params[:project_job][:start_date] + " " + @zone_time.strftime('%z'), "%m/%d/%Y %z" ) if params[:project_job][:start_date].present?
      e_date = DateTime.strptime(params[:project_job][:due_date] + " " + @zone_time.strftime('%z'), "%m/%d/%Y %z" ) if params[:project_job][:due_date].present?
         #.in_time_zone(@current_user.time_zone)
      params[:project_job][:start_date] = s_date 
      params[:project_job][:due_date] = e_date 
      params[:project_job].delete :project_type
      params[:project_job].delete :contactable_name_individual
      params[:project_job].delete :contactable_name_company
      
      minutes = params[:project_job][:estimate_hour].present? ? get_minutes_from_input_value( params[:project_job][:estimate_hour]) : 0
      if(!params[:project_job][:estimate_hour].present? && is_schedule_appoint)
        
        start_time = DateTime.strptime(Date.today.strftime("%m/%d/%Y") + " " + params[:due_date_start_time] +  " " +  @zone_time.strftime('%z'),"%m/%d/%Y %H:%M %z")
        end_time = DateTime.strptime(Date.today.strftime("%m/%d/%Y") + " " + params[:due_date_end_time]+  " " +  @zone_time.strftime('%z'),"%m/%d/%Y %H:%M %z")
        minutes =  (end_time.to_i - start_time.to_i) / 60
        
        params[:project_job][:estimate_hour] = (minutes / 60).to_s + ":" + (minutes % 60).to_s
      elsif( !is_schedule_appoint)
        start_time = DateTime.strptime(Date.today.strftime("%m/%d/%Y") + " 8:00"  +  @zone_time.strftime('%z'),"%m/%d/%Y %H:%M %z")
        end_time = start_time + minutes.minutes
      end
      
      
      # params[:project_job][:start_date] = Date.strptime(params[:project_job][:start_date], "%m/%d/%Y" )if params[:project_job][:start_date].present?
      # params[:project_job][:due_date] = Date.strptime(params[:project_job][:due_date], "%m/%d/%Y") if params[:project_job][:due_date].present?
      user_ids = params[:project_job][:notify_email_ids].split(",") if params[:project_job][:notify_email_ids].present?
      params[:project_job] = params[:project_job].merge(:last_updated_by=>@current_user.id) if(!params[:project_job][:last_updated_by].present?)
      
      @project_job = ProjectJob.new(params[:project_job])
      @project_job.organization_id = @current_user.organization_id
      @project_job.created_by = @current_user.id
      # if params[:project_job][:start_date].present?
      #   @project_job.start_date = Date.strptime(params[:project_job][:start_date], "%m/%d/%Y")
      # end
      # if params[:project_job][:due_date].present?
      #   @project_job.due_date = Date.strptime(params[:project_job][:due_date], "%m/%d/%Y")
      # end
      @project_job.project_id=params[:project_job][:project_id] if params[:project_job][:project_id].present?
      @project_job.project_stage_id = @project_job.project.project_stage_id
      @project_job.estimate_minutes = minutes
      if params[:project_job][:is_repeat] == "true"
        params[:project_job_repeat][:repeat_start] = DateTime.strptime(params[:project_job_repeat][:repeat_start], "%m/%d/%Y")
        params[:project_job_repeat][:repeat_end_on] = DateTime.strptime(params[:project_job_repeat][:repeat_end_on], "%m/%d/%Y") if params[:project_job][:repeat_end_on].present?
        @project_job_repeat = @project_job.build_project_job_repeat(params[:project_job_repeat])
      end
       
      # Send email to checked users
      if @project_job.save
        if(@project_job.estimate_minutes.present? && @project_job.estimate_minutes > 0 && @project_job.start_date.present? && @project_job.due_date.present?)
          distribute_hours_for_user(@project_job,@project_job.start_date)
        end
        create_in_app_notification("Create", "Created project job '#{@project_job.name}'")
        Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @project_job.created_by, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "Create", :activity_desc => @project_job.name, :activity_date => @project_job.created_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
        project_job_type = @current_organization.project_job_types.where(:original_id=> 1).first
        if(project_job_type.present?)
          @project_job.project_job_type_id == project_job_type.id
          attendees = User.where("id in (?)",params[:project_job][:assigned_to_users]).all
          if(attendees.present?)
            @project_job.assigned_to = attendees.first.id
            @project_job.save
          end
          if(params[:is_client_included].present?)
            if @project_job.project.linked_with == "Opportunity" && @project_job.project.lead.present? && @project_job.project.lead.individual_contact.present?
              client = @project_job.project.lead.individual_contact 
            elsif @project_job.project.linked_with == "Contact"  && @project_job.project.individual_contact.present?
              client = @project_job.project.individual_contact
            elsif @project_job.project.linked_with == "Organization"  && @project_job.project.company_contact.present?
              client = @project_job.project.company_contact
            end
          else  
            client = nil
          end
          # to be handled using sidekiq
          if(current_user.office_mail.present?)
            begin
              
              @project_job.insert_in_office365_calendar(current_user,attendees,start_time,end_time,client) if @project_job.project_job_type.original_id == 1
            rescue Exception => e
              p e.message
            end
          end
        end
        
        begin

          users_mail = @current_organization.users.where("id IN (?)",user_ids).collect(&:email).join(",")
          Notification.send_assigned_job_notification(users_mail, @project_job, @current_user).deliver if is_valid_user_email

          if(is_schedule_appoint)
            users_mail =attendees.collect(&:email).join(",")
            Notification.send_appointment_notification(users_mail, @project_job, @current_user,start_time,end_time).deliver if is_valid_user_email
          end
        rescue Exception => e
          
        end
        return true
      else
        return false
      end
    end
  end
  def update
    Time.zone = current_user.time_zone if current_user && current_user.time_zone
    @zone_time = Time.zone.now
    s_date =DateTime.strptime(params[:project_job][:start_date] + " " + @zone_time.strftime('%z'), "%m/%d/%Y %z" ) if params[:project_job][:start_date].present?
    e_date = DateTime.strptime(params[:project_job][:due_date] + " " + @zone_time.strftime('%z'), "%m/%d/%Y %z" ) if params[:project_job][:due_date].present?
       #.in_time_zone(@current_user.time_zone)
    params[:project_job][:start_date] = s_date 
    params[:project_job][:due_date] = e_date 

    modify_distribution = false
    minutes = get_minutes_from_input_value( params[:project_job][:estimate_hour])
    @project_job.estimate_minutes = minutes
    # if(@project_job.estimate_hour  != params[:project_job][:estimate_hour].to_i ||
    #   (@project_job.start_date.present? && @project_job.start_date.in_time_zone(@current_user.time_zone).to_date != params[:project_job][:start_date]) ||
    #   (@project_job.due_date.present? && @project_job.due_date.in_time_zone(@current_user.time_zone).strftime("%m/%d/%Y") != params[:project_job][:due_date])
    #   )
    if(@project_job.estimate_minutes  != minutes ||
      (@project_job.start_date.present? && @project_job.start_date.in_time_zone(@current_user.time_zone).to_date != params[:project_job][:start_date]) ||
      (@project_job.due_date.present? && @project_job.due_date.in_time_zone(@current_user.time_zone).strftime("%m/%d/%Y") != params[:project_job][:due_date])
      )
    modify_distribution = true
      remove_distribution_hours_for_user(@project_job)
    end
    if @project_job.update_attributes(params[:project_job])
      distribute_hours_for_user(@project_job,@project_job.start_date) if modify_distribution == true
      
      create_in_app_notification("Update", "Updated project job '#{@project_job.name}'")
      Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "Update", :activity_desc => @project_job.name, :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    end
    respond_to do |format|
      format.html redirect_to project_project_job_path(@project_job.project,@project_job)
      format.json { render json: ProjectJobsDatatable.new(view_context) }
      format.js {render "show_alert_message('success', 'Project Job updated successfully')"}
    end
    
  end

  def destroy
    
    @project_job.update_column :is_archive,true
    create_in_app_notification("Delete", "Deleted project job '#{@project_job.name}'")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "Delete", :activity_desc => @project_job.name, :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    remove_distribution_hours_for_user(@project_job)
    flash[:success] = "Job deleted successfully."
    redirect_to project_project_jobs_path(@project_job.project)
  end

  def create_comment
    @project_job = ProjectJob.find_by_id params[:project_job_id]
    @comment = @project_job.comments.new params[:comment]    
    if @comment.save
      @project_job.update_attributes(:assigned_to => @comment.assigned_to, :status => @comment.status, :priority => @comment.priority)
      @project_job.check_or_upgrade_project_stage
      begin
        user_ids = params[:comment][:user_id].split(",") if params[:comment][:user_id].present?
        users_mail = @current_organization.users.where("id IN (?)",user_ids).collect(&:email).join(",")
        create_in_app_notification("Create", "Created comment project job '#{@project_job.name}'")
        Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "Commented", :activity_desc => "Created comment project job '#{@project_job.name}'", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
      
        Notification.send_comment_notification(users_mail, @project_job, @current_user).deliver if is_valid_user_email
       rescue
       end
      if params[:file].present?
        params[:file].each do |file|
          begin
            note = Note.create!( :organization => @current_organization, :notable => @comment, :notes => params[:comment][:comment], :created_by => @current_user.id)
            note.note_attachments.create(:note_id => note.id, :attachment => file[1])
          rescue
          end
        end
      end
      # redirect_to "/projects/#{@project_job.project.id}/jobs/#{params[:project_job_id]}"
      @comment = @project_job.comments.new

      if request.format.json?
        render json: {
          html_data: render_to_string(partial: 'project_details')
        }
      else
        render partial: "project_details"
      end
    end
  end
  def get_user_list_for_project_job
    @project_job = ProjectJob.find(params[:project_job_id])
    if(@project_job.assigned_to == @current_user.id)
      @project_users = @project_job.project.project_users.where("user_id !=?",@current_user.id)
    else
      @project_users = @project_job.project.project_users.where("user_id !=?",@project_job.assigned_to)
    end
    render partial: "get_project_users"
  end
  def change_assign_user_for_job
    # begin
      @project_job = ProjectJob.find(params[:project_job_id])
      old_user_id = @project_job.assigned_to
      user = @current_organization.users.where("id=?",params[:user_id]).first
      new_user_id = params[:user_id]
      @project_job.update_attributes :assigned_to => params[:user_id], :last_updated_by => @current_user.id
      reassign_distribution_hours_to_other(@project_job,old_user_id,new_user_id)
      create_comment_activity("Task re-assigned to <b>#{user.full_name.present? ? user.full_name : user.email}</b>")
      create_in_app_notification("Update", "Task re-assigned to #{user.full_name.present? ? user.full_name : user.email}")
      Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "Re-assigned", :activity_desc => "Task re-assigned to #{user.full_name.present? ? user.full_name : user.email}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
      
      assign_user = @project_job.assigned_user
      Notification.send_assigned_user_job_notification(assign_user.email, @project_job, @current_user).deliver
      if @project_job.project.project_manager.present?
        Notification.send_assigned_job_notification_manager(assign_user.email, @project_job, @current_user).deliver
      end
      if params[:page].present?
        render text: user.full_name.present? ? ERB::Util.html_escape(user.full_name) : ERB::Util.html_escape(user.email)
      else  
        @comment = @project_job.comments.new
        render partial: "project_details"
      end
    # rescue => ex
    #   render :text=> ex.backtrace
    # end
  end
  def change_priority_for_project_job
    @project_job = ProjectJob.find(params[:project_job_id])
    @project_job.update_attributes :priority => params[:priority], :last_updated_by => @current_user.id
    create_comment_activity("Job priority changed to <b>"+params[:priority]+"</b>")
    create_in_app_notification("Update", "Job priority changed to #{params[:priority]}")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "PriorityChanged", :activity_desc => "Job priority changed to #{params[:priority]}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    if params[:page].present?
      render text: ERB::Util.html_escape(params[:priority])
    else  
      @comment = @project_job.comments.new
      render partial: "project_details"
    end
  end
  # Add new job type
  def create_job_type
    if params[:name].present?
      @project_job_type = ProjectJobType.where(organization_id: @current_organization.id, name: params[:name]).first
      if @project_job_type.present?
        if params[:custom].present?
          render json: {name: @project_job_type.name,id: @project_job_type.id, status: "success", msg: "Job type added successfully.", type: 'old'}
        else
          @project_job_types = @current_organization.project_job_types
          render partial: "list_job_type"
        end
      else
        @project_job_type = ProjectJobType.new
        @project_job_type.name = params[:name]
        @project_job_type.organization_id = @current_organization.id
        if @project_job_type.save
          if params[:custom].present?
            render json: {name: @project_job_type.name,id: @project_job_type.id, status: "success", msg: "Job type added successfully.", type: 'new'}
          else
            @project_job_types = @current_organization.project_job_types
            render partial: "list_job_type"
          end
        else
          if params[:custom].present?
            render json: {msg: "Job type name already exists!. Please enter another name.", status: "error"}
          end
        end
      end
    else
      render json: {msg: "Job type name should not be blank.", status: "error"}
    end
  end
  # Update job type
  def update_job_type
    @project_job_type = @current_organization.project_job_types.where("id=?",params[:id]).first
    @project_job_type.update_attributes :name => params[:name]
    @project_job_types = @current_organization.project_job_types
    render partial: "list_job_type"
  end
  # Delete job type
  def delete_job_type
    @job_type = @current_organization.project_job_types.find_by_id(params[:id])
    if @job_type.destroy
      render text: ERB::Util.html_escape("Success"), status: :ok
    else
      render text: ERB::Util.html_escape("Fail"), status: 406
    end
  end
  # Add new job group
  def create_job_group
    if params[:name].present? && params[:project_id].present?
      project_job_group = @current_organization.project_job_groups.where(project_id: params[:project_id], name: params[:name]).first
      if project_job_group.present?
        render json: {name: project_job_group.name, id: project_job_group.id, status: "success", msg: "Job group added successfully.", type: 'old'}
      else
        project_job_group = ProjectJobGroup.new
        project_job_group.name = params[:name]
        project_job_group.organization_id = @current_organization.id
        project_job_group.project_id = params[:project_id]
        if project_job_group.save
          if params[:custom].present?
            render json: {name: project_job_group.name, id: project_job_group.id, status: "success", msg: "Job group added successfully.", type: 'new'}
          else
            render json: {name: project_job_group.name, id: project_job_group.id, status: "success", msg: "Job group added successfully.", type: 'new'}
          end
        else
          if params[:custom].present?
            render json: {msg: "Job group name already exists!. Please enter another name.", status: "error"}
          else
            render json: {msg: project_job_group.errors.full_message, status: "error"}
          end
        end
      end
    else
      render json: {msg: "Job group name should not be blank.", status: "error"}
    end
  end
  # Update job group
  def update_job_group
    @project_job_group = @current_organization.project_job_groups.where("id=?",params[:id]).first
    @project_job_group.update_attributes :name => params[:name], :last_updated_by => @current_user.id
    @project_job_groups = @current_organization.project_job_groups
    render partial: "list_job_group"
  end
  # Delete job group
  def delete_job_group
    @job_group = @current_organization.project_job_groups.find_by_id(params[:id])
    if @job_group.destroy
      render text: ERB::Util.html_escape("Success"), status: :ok
    else
      render text: ERB::Util.html_escape("Fail"), status: 406
    end
  end
  # Get job type in job details page
  def get_job_types
    @project_job_types = @current_organization.project_job_types
    render partial: "get_job_types"
  end
  # Update job type in job details page
  def update_job_type_in_job_details
    @project_job = ProjectJob.find(params[:project_job_id])
    @project_job.update_column(:project_job_type_id, params[:job_type_id])
    create_comment_activity("Job type changed to <b>"+@project_job.project_job_type.name+ "</b>")
    create_in_app_notification("Update", "Job type changed to #{@project_job.project_job_type.name}")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "JobTypeChanged", :activity_desc => "Job type changed to #{@project_job.project_job_type.name}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    @comment = @project_job.comments.new
    render partial: "project_details"
  end
  def change_status_in_job_details
    @project_job = ProjectJob.find(params[:project_job_id])

    if @project_job.status.present? && @project_job.status != params[:status]
      @project_job.update_attributes :status => params[:status], :last_updated_by => @current_user.id
      if(params[:status] == "Resolved")
        @project_job.resolved_at = Time.now
        @project_job.save
      end
      if(params[:status] == "Closed")
        @project_job.closed_at = Time.now
        @project_job.save
      end
      @project_job.check_or_upgrade_project_stage
      create_comment_activity("<b>"+params[:status]+ "</b> the Task")
      create_in_app_notification("Update", "Job status changed to #{params[:status]}")
      Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "StatusChanged", :activity_desc => "Job status changed to #{params[:status]}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    end
    if params[:page].present?
      render text: ERB::Util.html_escape(params[:status])
    else 
      @comment = @project_job.comments.new
      render partial: "project_details"
    end
  end
  def update_job_status
    @project_job = ProjectJob.find(params[:project_job_id])
    @project_job.update_attributes :status => params[:status], :last_updated_by => @current_user.id
    @project_job.check_or_upgrade_project_stage
    create_comment_activity("<b>"+params[:status]+ "</b> the Task")
    create_in_app_notification("Update", "Job status changed to #{params[:status]}")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "StatusChanged", :activity_desc => "Job status changed to #{params[:status]}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    render text: "Updated the job status successfully!"
  end
  def get_kanban_view
    if params[:project_id].present? && params[:project_id] != 'All'
      @project = @current_organization.projects.find(params[:project_id])
    end
    type = params[:type].present? ? params[:type] : 'all_user'
    if !params[:user_id].present?
      params[:user_id] = 'All'
    end
    if params[:user_id].present? || params[:project_id].present?
      render :partial => "get_kanban_view",:locals=>{:type=>type}
    else  
      render :partial => "show_kanban_view",:locals=>{:type=>type}
    end
  end
  def list_project_job_group
    project_job = ProjectJob.where(:id=>params[:project_job_id]).first
    @project_job_groups = project_job.project.project_job_groups
    render partial: "list_project_job_group"
  end
  def get_project_job_group
    
    project_job = ProjectJob.where(:id=>params[:project_job_id]).first
    project_job_groups = project_job.project.project_job_groups
    render partial: "get_project_job_group",:locals=>{:project_job => project_job,:project_job_groups=>project_job_groups}
   
  end
  def update_job_group_in_job_details
    @project_job = ProjectJob.find(params[:project_job_id])
    @project_job.update_column(:project_job_group_id,params[:job_group_id])
    create_comment_activity("Job group changed to <b>"+@project_job.project_job_group.name+ "</b>")
    create_in_app_notification("Update", "Job group changed to #{@project_job.project_job_group.name}")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "GroupChanged", :activity_desc => "Job group changed to #{@project_job.project_job_group.name}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    @comment = @project_job.comments.new
    render partial: "project_details"
  end
  def update_job_group_for_job
    @project_job = ProjectJob.find(params[:project_job_id])
    @project_job.update_column(:project_job_group_id,params[:job_group_id])
    create_comment_activity("Job group changed to <b>"+@project_job.project_job_group.name+ "</b>")
    create_in_app_notification("Update", "Job group changed to #{@project_job.project_job_group.name}")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "GroupChanged", :activity_desc => "Job group changed to #{@project_job.project_job_group.name}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    render text: "success"
  end
  def update_job_progress
    @project_job = ProjectJob.find(params[:project_job_id])
    @project_job.update_attributes :progress => params[:progress], :last_updated_by => @current_user.id
    create_comment_activity("Job progress changed to <b>"+params[:progress]+ "%</b>")
    create_in_app_notification("Update", "Job progress changed to #{params[:progress]}%")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "ProgressChanged", :activity_desc => "Job progress changed to #{params[:progress]}%", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    render text: ERB::Util.html_escape(params[:progress])
  end
  def update_estimated_hours
    @project_job = ProjectJob.find(params[:project_job_id])
    remove_distribution_hours_for_user(@project_job)
    # value = params[:value].split(":")
    # minutes = value[0].to_i * 60 
    # minutes += value[1].to_i if(value[1].present?)
    minutes = get_minutes_from_input_value(params[:value])
    puts "...................minutes calculated"
    p minutes
    @project_job.update_attributes :estimate_hour => params[:value],:estimate_minutes => minutes, :last_updated_by => @current_user.id
    distribute_hours_for_user(@project_job,@project_job.start_date)
    create_comment_activity("Job estimate hour changed to <b>"+params[:value] + "</b> hours")
    create_in_app_notification("Update", "Job estimate hour changed to #{params[:value]} hours")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "EstimateChanged", :activity_desc => "Job estimate hour changed to #{params[:value]} hours", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    @comment = @project_job.comments.new
    render partial: "project_details"
  end

  def create_comment_activity(desc)
    @project_job.comments.create(:comment => desc, :user_id => @current_user.id, :priority => "low", :status => "New")
  end
  def update_due_date
    Time.zone = @current_user.time_zone
    @project_job = ProjectJob.find(params[:project_job_id])
    remove_distribution_hours_for_user(@project_job)
    date = DateTime.strptime(params[:date] + " 00:00am " + Time.zone.now.strftime('%z'),"%d-%m-%Y %H:%M%p %z" )
    #date = DateTime.parse(params[:date]).in_time_zone(@current_user.time_zone)
    @project_job.update_attributes :due_date => date, :last_updated_by => @current_user.id
    distribute_hours_for_user(@project_job,@project_job.start_date)
    create_comment_activity("Due date changed to <b>"+date.strftime("%b %d, %a") + "</b>")
    create_in_app_notification("Update", "Due date changed to #{date.strftime("%b %d, %a")}")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "DueDateChanged", :activity_desc => "Due date changed to #{date.strftime("%b %d, %a")}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    if params[:page].present?  
      render text: ERB::Util.html_escape(date.strftime("%b %d, %a"))
    else
      @comment = @project_job.comments.new
      render partial: "project_details"
    end
  end

  # Update catchup later
  def update_catchup_later
    @project_job = ProjectJob.find_by_id(params[:project_job_id])
    @project_job.update_attributes :catchup_later => true, :status => "Blocked", :last_updated_by => @current_user.id
    @project_job.check_or_upgrade_project_stage
    create_comment_activity("Added to <b>Blocked</b>")
    create_in_app_notification("Update", "Updated project job '#{@project_job.name}' to catchup later")
    Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "StatusChanged", :activity_desc => "Updated project job '#{@project_job.name}' to catchup later", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
    @comment = @project_job.comments.new
    render partial: "project_details"
  end

  def job_listing
    render partial: "jobs_list"
  end

  def jobs_list
    p request.path
    @project = @current_organization.projects.find_by_id(params[:project_id])
    render partial: "jobs_list", :locals => {project: @project}
  end

  def calendar_view
    @project = @current_organization.projects.find_by_id(params[:project_id])
    render partial: "calendar_view"
  end

  def jobs_calendar_data
    if request.xhr?
      events = []
      start_date,end_date="",""
      start_date =Time.zone.at(params[:start].to_i).strftime("%Y/%m/%d") if params[:start].present?
      end_date =Time.zone.at(params[:end].to_i).strftime("%Y/%m/%d") if params[:end].present?
      
      if params[:project_id].present?
        @project = Project.where("id=?",params[:project_id]).first
        @project_jobs = @project.project_jobs
      end
      if params[:filter_type].present? && params[:filter_type] == "all"
        @project_jobs=@project_jobs.where("DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') BETWEEN ? AND ?", Time.zone.now.utc_offset, start_date, end_date )
      else
        @project_jobs=@project_jobs.where("is_completed = ? and DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') BETWEEN ? AND ? and (DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') = ? or DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') > ?)",  false, Time.zone.now.utc_offset, start_date, end_date, Time.zone.now.utc_offset, Time.zone.now.strftime("%Y/%m/%d"), Time.zone.now.utc_offset,Time.zone.now.strftime("%Y/%m/%d") )
      end

      @project_jobs.each do |project_job|
        events << {:is_complete=> project_job.is_completed, :tasktype=> project_job.project_job_type.present? ? project_job.project_job_type.name : "None" , :assign_to=> "#{(project_job.created_user.present? ? project_job.created_user.full_name : 'NA')}", :url=> "http://#{request.host_with_port}/projects/#{@project.id}/jobs/#{project_job.id}", :title => "\n"+project_job.name+ "\n" ,   :color=> ProjectJob::JOB_COLORS[project_job.status], :description => "At - #{project_job.due_date.present? ? project_job.due_date.strftime('%H:%M') : ''}\nJob - "+project_job.name+"\n Project - " + project_job.name+"\nAssigned To - "+(project_job.created_user ? project_job.created_user.full_name : ""), :start => "#{project_job.due_date.iso8601}", :end => "#{project_job.due_date.iso8601}", :allDay => false}
      end
    end
    respond_to do |format|
      format.json { render json: events}
    end
  end
  
  # NEXT / PREVIOUS FUNCTIONALITY
  def fetch_job_content
    ids = @project_job.project.project_jobs.map(&:id)
    if params[:type] == "refresh"
      @comment = @project_job.comments.new
      render partial: "project_details"
    else
      begin
        if params[:type] == "next"
          project_id =  @project_job.project.id
          unless ids.nil?
            index = ids.find_index(@project_job.id)
            next_id = ids[index+1] unless index == ids.size
            @project_job = @project_job.project.project_jobs.where("id=?",next_id).first
          end
          
        else
          project_id =  @project_job.project.id
          unless ids.nil?
            index = ids.find_index(@project_job.id)
            prev_id = ids[index-1] unless index.zero?
            @project_job = @project_job.project.project_jobs.where("id=?",prev_id).first
          end
        end
        redirect_to "/projects/#{@project_job.project.id}/jobs/#{@project_job.id}"
      rescue
        redirect_to "/projects/#{project_id}/jobs"
      end
    end
  end

  def update_mass_project_jobs
    project = @current_organization.projects.where("id = ?", params[:project_id]).first    
    if params[:type] == "resolve"
      jobs = @current_organization.project_jobs.where("id IN (?)", params[:resolve_job_ids].split(","))
      jobs.update_all :status=>"Resolved", :resolved_at => Time.now
      project.move_to_next_stage
    else
      jobs = @current_organization.project_jobs.where("id IN (?)", params[:close_job_ids].split(","))
      jobs.update_all :status=>"Closed", :closed_at => Time.now
      project.move_to_next_stage
    end
    redirect_to project_project_jobs_path(project)
  end
  def show_kanban_view
    render :partial => "show_kanban_view",:locals=>{type: params[:type]}
   
  end
  def change_project_job_status
    # begin
      status = params[:status]
      @project_job = @current_organization.project_jobs.find_by_id(params[:project_job_id])
      if status.present? && @project_job.status.present? && @project_job.status != status
        @project_job.update_attribute :status, status
        @project_job.check_or_upgrade_project_stage
        @project = @project_job.project    
        create_comment_activity("<b>"+params[:status]+ "</b> the Task")
        create_in_app_notification("Update", "Job status changed to #{params[:status]}")
        Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "StatusChanged", :activity_desc => "Job status changed to #{params[:status]}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
      end
        # params[:user_id] = params[:user_id]=="All" ? "" : params[:user_id]
        render :json => {status: "success", project_id: @project.id}
    # rescue => ex
      # render :text => ex.message
    # end
  end
  def get_time_log_form
    @project_job = ProjectJob.find(params[:project_job_id])
    if(params[:jtl_id].present? && params[:jtl_id] != 'undefined')
      jobtimelog = JobTimeLog.where(:id=>params[:jtl_id]).first
    else
      jobtimelog = JobTimeLog.new(:project_job_id=>@project_job.id,:organization_id=>@current_user.organization_id)  
    end
    render :partial=>"project_jobs/time_log_form",:locals=>{:jobtimelog => jobtimelog}
  end
  def job_time_log_create
    Time.zone = @current_user.time_zone
    if(params[:job_time_log][:id].present?)
      jtl=JobTimeLog.where(:id=>params[:job_time_log][:id]).first
    else
      jtl = JobTimeLog.new
    end
    jtl.organization_id=@current_user.organization_id
    jtl.project_job_id = params[:job_time_log][:project_job_id]
    jtl.is_billable = params[:job_time_log][:is_billable]
    if(params[:job_time_log][:log_start_time].present? && params[:job_time_log][:log_end_time].present?)
      jtl.log_start_time = DateTime.strptime(params[:job_time_log][:log_start_date]+ " " + params[:job_time_log][:log_start_time]+ " " + Time.zone.now.strftime('%z'),"%m/%d/%Y %H:%M%p %z" )
      jtl.log_end_time = DateTime.strptime(params[:job_time_log][:log_start_date]+ " " + params[:job_time_log][:log_end_time]+ " " + Time.zone.now.strftime('%z'),"%m/%d/%Y %H:%M%p %z" )
    else
      #dt = strftime.new(params[:job_time_log][:log_start_date],"%m/%d/%Y")
      puts params[:job_time_log][:log_start_date]
      puts DateTime.strptime(params[:job_time_log][:log_start_date],"%m/%d/%Y")
      date = DateTime.strptime( params[:job_time_log][:log_start_date] + " 00:00am " + Time.zone.now.strftime('%z'),"%m/%d/%Y %H:%M%p %z" )
      jtl.log_start_time = date
      jtl.log_end_time = date
    end
    break_time_in_secs = 0
    if(params[:job_time_log][:break_time].present?)
      brk_arr = params[:job_time_log][:break_time].split(":")
      break_time_in_secs = (brk_arr[0].to_i )*60*60
      break_time_in_secs += (brk_arr[1].to_i) *60
    end
    jtl.break_time =  break_time_in_secs
    spent_hours_in_secs = 0
    if(params[:job_time_log][:spent_hours].present?)
      spt_arr = params[:job_time_log][:spent_hours].split(":")
      spent_hours_in_secs = (spt_arr[0].to_i )*60*60
      spent_hours_in_secs += (spt_arr[1].to_i) *60
    end
    jtl.spent_hours =  spent_hours_in_secs
    jtl.note =  params[:job_time_log][:note]
    jtl.user_id =  params[:job_time_log][:user_id]
    
    jtl.save
    jtl.project_job.save
    respond_to do |format|
      format.html{render :text=>"Time log saved successfully!"}
      format.js { render :js=>"closeTimeLogPopup(#{jtl.project_job_id})"}
    end
  end
  def remove_job_time_log
    jobtimelog = JobTimeLog.where(:id=>params[:jtl_id]).first
    if(jobtimelog.present?)
      if(jobtimelog.destroy)
        respond_to do |format|
          format.html{render :text=>"Time log removed successfully!"}
          format.js { render :js=>"refreshTimeLogsList(#{jobtimelog.project_job_id})"}
        end
      else
        respond_to do |format|
          format.html{render :text=>"Error in removing Time Log"}
          format.js { render :js=>"refreshTimeLogsList(#{jobtimelog.project_job_id})"}
        end
      end
    end
  end
  def get_job_time_logs
    @project_job = ProjectJob.where(:id=>params[:project_job_id]).first
    render :partial=>"project_jobs/list_job_time_log",:locals=>{:project_job=>@project_job}
  end
  def get_job_time_stats
    @project_job = ProjectJob.where(:id=>params[:project_job_id]).first
    render :partial=>"project_jobs/project_job_time_stat",:locals=>{:project_job=>@project_job}
  end
  # change project job status from job details page.
  def change_job_status_from_details
    @project_job = @current_organization.project_jobs.find(params[:id])
    if params[:status].present?
      if @project_job.status.present? && @project_job.status != params[:status]
        @project_job.update_column(:status, params[:status])
        @project_job.check_or_upgrade_project_stage      
        create_comment_activity("<b>"+params[:status]+ "</b> the Task")
        create_in_app_notification("Update", "Job status changed to #{params[:status]}")
        Activity.create(:organization_id => @project_job.organization_id, :activity_user_id => @current_user.id, :activity_type => @project_job.class.name, :activity_id => @project_job.id, :activity_status => "StatusChanged", :activity_desc => "Job status changed to #{params[:status]}", :activity_date => @project_job.updated_at, :is_public => true, :source_id => @project_job.project.id,:source_type => @project_job.project.class.name)
      end
    end
    render partial: "project_job_status_bar"
  end
  def fetch_user_jobs
    @project_jobs = ProjectJob.where(:assigned_to => params[:id]).where("due_date = ? ", Date.today).all
    respond_to do |format|
      format.text { render partial: "users/jobs_list" }
    end
  end
  def create_in_app_notification(type, desc)
    InAppNotification.create(:organization_id => @project_job.organization_id, :user_id => @project_job.assigned_to, :notificationable_type => @project_job.class.name, :notificationable_id => @project_job.id, :activity_type => type, :message => desc)
    if @project_job.project.present? && (project_manager_id = @project_job.project.project_manager_id).present?
      InAppNotification.create(:organization_id => @project_job.organization_id, :user_id => project_manager_id, :notificationable_type => @project_job.class.name, :notificationable_id => @project_job.id, :activity_type => type, :message => desc)
    end
  end
  def fetch_jobs
    where = build_where_clause
    if @current_user.is_admin?  
      jobs = @current_organization.project_jobs
    else
      jobs = @current_organization.project_jobs.where(where).where("(created_by=? OR assigned_to=? )", @current_user.id, @current_user.id)
    end
    case params[:job_by_duration]
    when "today"
      if @current_user.is_admin?
        @jobs=jobs.where(where).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
      else
        @jobs=jobs.where(where).where("( created_by=? OR assigned_to=? ) AND is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", @current_user.id, @current_user.id ,false, Time.zone.now.strftime("%Y/%m/%d"))
      end
    when "overdue"
      if @current_user.is_admin?  
        @jobs=jobs.where(where).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
      else
        @jobs=jobs.where(where).where("( created_by=? OR assigned_to=? ) AND is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", @current_user.id, @current_user.id, false, Time.zone.now.strftime("%Y/%m/%d"))
      end
    when "upcoming"
      if @current_user.is_admin?
        @jobs=jobs.where(where).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
      else
        @jobs=jobs.where(where).where("( created_by=? OR assigned_to=? ) AND is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", @current_user.id, @current_user.id, false, Time.zone.now.strftime("%Y/%m/%d"))
      end
    else
      if @current_user.is_admin?
        @jobs=jobs.where(where)
      else
        @jobs=jobs.where(where).where("( created_by=? OR assigned_to=? ) AND is_completed=?", @current_user.id, @current_user.id, false)
      end
    end
    @jobs=@jobs.order("created_at desc").limit(10)
    render partial: "user_jobs_list"
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
  end
  private
  def set_project_job
    @project_job = ProjectJob.find(params[:id])
    @project = @project_job.project
  end
  def reassign_distribution_hours_to_other(project_job,old_user_id,new_user_id)
    ## Get timelog entry for the task by the old user
    p "old user id ................................"
    p old_user_id
    p "new user id ................................."
    p new_user_id
    log_old_user = JobTimeLog.where(:project_job_id=>project_job.id, :user_id=>old_user_id).select("sum( COALESCE(spent_hours,0)) spent_hours").first
    p "log_old_user .................."
    p log_old_user
    ## spent hours are saved in second in timelog
    log_count_old_user = log_old_user.spent_hours if log_old_user.present?
    p log_count_old_user
    if(log_count_old_user.present? )
      # if(log_count_old_user < project_job.estimate_hour * 3600)
      if(log_count_old_user < project_job.estimate_minutes * 60)
        ## project_job.estimate_hour is saved in hour format
        ## timelog entry is saved in seconds
        ## Also find if any other use has been pre-assigned to the same task and present in time log entry
        log_other_old_user = JobTimeLog.where(:project_job_id=>project_job.id).where("user_id != ?",old_user_id).select("sum( COALESCE(spent_hours,0)) spent_hours").first
        log_count_other_old_user =  log_other_old_user.present? && log_other_old_user.spent_hours.present? ? log_other_old_user.spent_hours : 0
        #remaining_log_count = project_job.estimate_hour * 3600.0  - (log_count_old_user+log_count_other_old_user)
        remaining_log_count = project_job.estimate_minutes * 60.0  - (log_count_old_user+log_count_other_old_user)
        p "remaining_log_count ........................."
        p remaining_log_count
        ## Now find days remaining for resource allocation
        if(project_job.start_date > Date.today) ## future jobs allocation are changed
          ## no issues
          puts "no issues found ................future jobs allocation are changed..........."
          distribute_hours_for_user(project_job,project_job.start_date)
        elsif(project_job.start_date <= Date.today) ## running or old jobs are changed
          ## remove the previous job allocation for the old user
          p "rmoving the previous distribution..........................."
          ResourceDistribution.where(:project_job_id=>project_job.id, :user_id=>old_user_id).destroy_all
          ## get all time logs of the old user
          p "get all time logs of the old user............."
          jobtimelogs = JobTimeLog.where(:project_job_id=>project_job.id, :user_id=>old_user_id).select("sum(spent_hours) spent_hours,project_job_id,DATE(log_start_time) log_start_time").where("DATE(log_start_time) <= ?",Date.today).group("project_job_id,DATE(log_start_time)").all
          ## remove future time log entry of the old user
          p "remove future time log entry of the old user"
          JobTimeLog.where(:project_job_id=>project_job.id, :user_id=>old_user_id).where("DATE(log_start_time) > ?",Date.today ).destroy_all

          ## save the existing hours as the allocated hours for the old user
          jobtimelogs.each do |jtl|
            p "Create new time log for remaining hours"
            ResourceDistribution.create({
              :organization_id=>@current_user.organization_id,
              :project_id=> project_job.project_id,
              :project_job_id=> project_job.id,
              :user_id => old_user_id,
              :allotted_time => jtl.spent_hours/60, 
              :allotted_date => jtl.log_start_time
              })

          end
           ## now save the remaining estimated hours to the new user
          distribute_hours_for_user(project_job,Date.today,(remaining_log_count / 60.0))
        end
      end
    else
      ResourceDistribution.where(:project_job_id=>project_job.id, :user_id=>old_user_id).update_all(:user_id=>new_user_id)
    end
    
  end
  ## distribution removal is supposed to be before any change in project job update.
  def remove_distribution_hours_for_user(project_job)
    puts "coming to remove_distribution_hours_for_user .........................."
    past_dates = project_job.job_time_logs.where("user_id = ? and log_start_time < ?",project_job.assigned_to, Date.today).all.map(&:log_start_time).map(&:to_date)
    p past_dates
    if(past_dates.present?)
      ResourceDistribution.where(:project_job_id=>project_job.id, :user_id=>project_job.assigned_to).where("allotted_date not in (?)",past_dates).delete_all
    else
      ResourceDistribution.where(:project_job_id=>project_job.id, :user_id=>project_job.assigned_to).delete_all
    end
  end

  
  def distribute_hours_for_user(project_job,start_date=Date.today,estimate_minutes=0)
    # if(project_job.estimate_hour.present?)
    if(project_job.estimate_minutes.present?)
      puts "coming to distribute_hours_for_user .........................."
      if(estimate_minutes == 0 && (jtsl = project_job.job_time_logs.where("log_start_time <= ? ",Date.today)).count > 0)
        #estimate_minutes = (project_job.estimate_hour * 60.0 ) - ( jtsl.sum(:spent_hours) / 60)

        estimate_minutes = (project_job.estimate_minutes  ) - ( jtsl.sum(:spent_hours) / 60.0)
    
      end
      if !(start_date.present?)
        return
      end
      days_count =  (project_job.due_date.to_date - start_date.to_date)
      puts "days count --------------------------------------"
      puts days_count
      days = []
      weekends = current_user.organization.resource_setting.week_off_days
      valid_days = []
      if(days_count == 0)
        ## case - 1: if only single day is selected, then it will simply ignore if it is a weekend
        days << start_date.to_date
        valid_days << start_date.to_date
      else
        ## case - 2: if multiple days are selected, 
        ## => first add all days to the array
        (0..days_count).step(1) do |index|
          days << start_date.to_date + (index).days
        end
        puts " days ............................."
        p days
        ## => Check if any weekends are there
        days.each do |day|
          if(!(weekends.include? (day.wday)) && day >= Date.today)
            valid_days << day
          end
        end
        
        ## => If valid_days not found, then forcefully distribute the estimated hours to weekends
        if(valid_days.count == 0)
          valid_days = days
        end
      end
      valid_days = valid_days.uniq
      ## => Now calculate number of valid days
      valid_days_count = valid_days.length
      #if(project_job.estimate_hour.present? && estimate_minutes == 0)
      if(project_job.estimate_minutes.present? && estimate_minutes == 0)
        #minutes_per_day = (project_job.estimate_hour * 60.0) / valid_days_count
        minutes_per_day = (project_job.estimate_minutes.to_f) / valid_days_count
        
      else
        minutes_per_day = (estimate_minutes ) / valid_days_count
      end
      residual = 0
      if(estimate_minutes != minutes_per_day * valid_days.count )
        residual = estimate_minutes - (minutes_per_day * valid_days.count )
      end
      puts "valid days ............................."
      p valid_days
      valid_days.each do |vday|
        rd = ResourceDistribution.create({
          :organization_id=>@current_user.organization_id,
          :project_id=> project_job.project_id,
          :project_job_id=> project_job.id,
          :user_id => project_job.assigned_to,
          :allotted_time => minutes_per_day, 
          :allotted_date => vday
          })

      end
      ## adjust the residual minutes to the last day
      ## residual minutes come if the division of estimated minutes by an odd number of days
      if(residual > 0)
        rd.allotted_time = rd.allotted_time + residual
        rd.save
      end
    end
  end
  def get_minutes_from_input_value(input_value)
    p input_value
    value = input_value.split(":")
    p value
    minutes = value[0].to_i * 60 
    p minutes
    minutes += value[1].to_i if(value[1].present?)
    p minutes

  end
end

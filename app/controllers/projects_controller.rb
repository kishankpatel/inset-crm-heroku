require 'will_paginate/array'
class ProjectsController < ApplicationController
  before_filter :set_project, only: [:show, :edit, :update, :destroy, :complete_project, :add_project_user, :update_project_users, :archive_project]
  
  def index
    #@projects = @current_organization.projects
  # begin
    params[:cuser] = current_user.id
    respond_to do |format|
      format.html
      format.json { render json: ProjectsDatatable.new(view_context) }
    end
  # rescue => ex
  #     p ex.message
  # end
  end

  def show    
    @deal = @project.deal
    if @deal.present? && @deal.deals_contacts.present? && @deal.deals_contacts.first.contactable.present?
      @contact = @deal.deals_contacts.first.contactable
    end
    if @deal.present?
      @invoices = @deal.invoices.where(invoice_type: "invoice").order("created_at desc")
    end
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    err_msg = ""
    succ_msg = ""
    
      if params[:project][:start_date].present?
        params[:project][:start_date] = Date.strptime(params[:project][:start_date], "%m/%d/%Y")
      end
      if params[:project][:end_date].present?
        params[:project][:end_date] = Date.strptime(params[:project][:end_date], "%m/%d/%Y")
      end
      if params[:project][:id].present?
        action = "update"
        @project = Project.find(params[:project][:id])
        if @project.present?
          @project.update_attributes(params[:project])
        end
      else
        action = "new"
        @project = Project.new(params[:project])
      end
      

      if @project.save
        project_users = @project.project_users
        if(params[:project][:project_users_attributes].present?)
          params[:project][:project_users_attributes].each do |k,v|
            if v[:id].present? && v[:user_id].present?
              # unless project_users.where(user_id: v[:user_id].to_i, id: v[:id].to_i).present?
              #   @project.project_users.build(:user_id => v[:user_id].to_i, :id => v[:id].to_i)
              # end
            else
              if v[:id].present? && !v[:user_id].present?
                pusers = project_users.where(id: v[:id].to_i).delete_all
              elsif !v[:id].present? && v[:user_id].present?
                @project.project_users.build(:user_id => v[:user_id].to_i)
              end
            end
          end
        end
        unless(project_users.where(user_id: params[:project][:project_manager_id].to_i).present?)
        
          @project.project_users.build(:user_id => params[:project][:project_manager_id])
        end

        if action == "update"
          Activity.create(:organization_id => @project.organization_id, :activity_user_id => @project.created_by, :activity_type => @project.class.name, :activity_id => @project.id, :activity_status => "Update", :activity_desc => @project.name, :activity_date => @project.created_at, :is_public => true, :source_id => @project.id,:source_type=>@project.class.name)
          succ_msg = "Project has been updated successfully<br>"
        else
          Activity.create(:organization_id => @project.organization_id, :activity_user_id => @project.created_by, :activity_type => @project.class.name, :activity_id => @project.id, :activity_status => "Create", :activity_desc => @project.name, :activity_date => @project.created_at, :is_public => true, :source_id => @project.id,:source_type=>@project.class.name)
          succ_msg = "Project has been created successfully<br>"
        end
        if params[:invite_user] == "true"
          user_emails = params[:users_email].split(",")
          user_emails.each do |user_email|
            begin
              if EmailVerifier.check(user_email)
                user = User.where("email = ?", user_email).first
                if !user.present?
                  user=User.new
                  user.email = user_email
                  user.admin_type = 3
                  user.organization= @current_organization
                  user.password = Devise.friendly_token[0,10]
                  # user.build_user_role(:role_id=> 1, :organization_id => user.organization_id) 
                  if user.save
                    user.invite!(@current_user) if is_valid_user_email 
                    p "Invitation email send to user: #{user_email}"
                    ProjectUser.create(project_id: @project.id, user_id: user.id)
                    succ_msg = succ_msg + "Invitation send to: #{user_email}<br>"
                  end
                else
                  if @current_organization.users.where("email=?",user_email).first
                    err_msg = err_msg + "Invited by other Organization: #{user_email}<br>"
                  else
                    err_msg = err_msg + "Already present in your Organization: #{user_email}<br>"
                  end
                  p "Already invited: #{user_email}<br>"
                end
              else
                err_msg = err_msg + "Invalid email: #{user_email}<br>"
              end
            rescue
              err_msg = err_msg + "Something went wrong with: #{user_email}<br>"
            end
          end
        end
        flash[:notice] = succ_msg
        flash[:alert] = err_msg
        if action == "update"
          redirect_to project_path(@project)
        else
          redirect_to "/projects"
        end
      else
        flash[:alert] = @project.errors.full_messages
        puts "---------->>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<-------------"
        p @project.errors.full_messages

        redirect_to "/projects"
        #render :text=> @project.errors.full_messages
      end
    
    
  end

  def update
    if @project.update_attributes(params[:project])
      Activity.create(:organization_id => @project.organization_id, :activity_user_id => @project.created_by, :activity_type => @project.class.name, :activity_id => @project.id, :activity_status => "Update", :activity_desc => @project.name, :activity_date => @project.created_at, :is_public => true, :source_id => @project.id,:source_type=>@project.class.name)
    end
  end

  def open_project_popup
    p params
    if params[:id].present?
      @project = Project.find(params[:id])
    else
      @project = Project.new(:organization_id=>current_user.organization_id)
    end
    puts "checking if contacts are present?........................."
    puts params[:contact_type].present? && params[:contact_id].present?
    if(params[:contact_type].present? && params[:contact_id].present?)
      if(params[:contact_type] == "IndividualContact")
        @contact = IndividualContact.where(:id=>params[:contact_id],:organization_id=>current_user.organization_id).first
        @project.individual_contact_id = params[:contact_id]
      end
    end
    if(params[:deal_id].present?)
      @deal = Deal.where(:id=>params[:deal_id],:organization_id=>current_user.organization_id).first
      @project.deal_id = params[:deal_id]
      @project.linked_with = "Opportunity"
    end
    p @project
    render partial: "project_form_div"
  end

  def destroy
    project_jobs = @project.project_jobs
    if project_jobs.present?
      project_jobs.destroy_all
    end
    @project.destroy
  end

  def board_view
    @projects = @current_organization.projects.order("created_at desc")
  end

  def details_view
    @projects = @current_organization.projects.order("created_at desc")
  end
# Add new project task type
  def create_project_task_type
    if params[:name].present?
      @project_task_type = ProjectTaskType.new
      @project_task_type.name = params[:name]
      @project_task_type.organization_id = @current_organization.id
      @project_task_types = @current_organization.project_task_types
      if @project_task_type.save
        if params[:custom].present?
          render json: {name: @project_task_type.name,id: @project_task_type.id, status: "success", msg: "Project type added successfully."}
        else
          render partial: "list_project_task_type"
        end
      else
        if params[:custom].present?
          render json: {msg: "Project type name already exists!. Please enter another name.", status: "error"}
        end
      end
    else
      render json: {msg: "Project type name should not be blank.", status: "error"}
    end
  end
  # Update project task type
  def update_project_task_type
    @project_task_type = @current_organization.project_task_types.where("id=?",params[:id]).first
    @project_task_type.update_attributes :name => params[:name]
    @project_task_types = @current_organization.project_task_types
    render partial: "list_project_task_type"
  end


  #complete project action
  def complete_project
    begin
      if params[:type] == 'reopen'
        @project.update_attributes(:status => "Re-opened", :is_completed => false)
      else
        @project.update_attributes(:status => "Completed", :is_completed => true)
      end
      render json: {:status => "success"}
    rescue
      render json: {:status => "error"}
    end
  end


  #complete mass project action
  def complete_mass_project
    begin
      if params[:project_ids_to_complete].present?
        projects = @current_organization.projects.where("id IN (?)", params[:project_ids_to_complete].split(","))
        projects.each{|p| p.update_attributes(:is_completed => true, :status => "Completed")}
      end
      render json: {:status => "success"}
    rescue
      render json: {:status => "error"}
    end
  end

  #archive project action
  def archive_project
    begin
      @project.update_column(:is_archive,true)
      if (deal = @project.deal).present?
        if deal.projects.count == 0
          deal.update_column :is_project, false
        end
      end
      render json: {:status => "success"}
    rescue
      render json: {:status => "error"}
    end
  end


  #archive mass project action
  def archive_mass_project
    begin
      if params[:project_ids_to_archive].present?
        projects = @current_organization.projects.where("id IN (?)", params[:project_ids_to_archive].split(","))
        projects.update_all :is_archive=>true
      end
      render json: {:status => "success"}
    rescue
      render json: {:status => "error"}
    end
  end

  def projects_list
    render partial: "projects_list"
  end

  def add_project_user
    render partial: "add_user_dual_list"
  end

  def update_project_users
    begin
      if params[:add_user_ids].present?
        add_users = @current_organization.users.where("id IN (?)", params[:add_user_ids].split(","))
        add_users.map {|u| @project.project_users.create(:user_id => u.id)}
      end
      if params[:remove_user_ids].present?
        remove_users = @current_organization.users.where("id IN (?)", params[:remove_user_ids].split(","))
        remove_users.map {|u| @project.project_users.find_by_user_id(u.id).destroy }
      end    
      
      render json: {:status => "success", :users_count => @project.project_users.map{|p|p.user}.compact.count}
    rescue
      render json: {:status => "error"}
    end
  end  
  def get_projects_list
    @projects = @current_organization.projects.active_multi_filter(params)
    render partial: ERB::Util.html_escape(params[:page])
  end
  def get_projects
    if !params[:org_id].nil?
      # if current_user.is_admin?
        projects = Project.where("organization_id = ? and name like ?", params[:org_id], params[:q]+"%").select("name as project_name, id")
      # else
      #   projects = Project.where("organization_id = ? and name like ?  and ( created_by = ?)", params[:org_id], params[:q]+"%", true, current_user.id).select("name as project_name, id")
      # end
      respond_to do |format|
        format.json { render json: projects }
      end
    end

  end
  def get_kanban_view
    
    cookies.delete(:open_all_type)
    cookies[:open_all_type] = params[:open_all_type]
    if params[:user_id].present?
      render :partial => "get_kanban_view"
    else  
      render :partial => "show_kanban_view"
    end
  end
  def get_assigned_to_users
    @project = Project.find(params[:project_id])
    if(@project.project_type == 'Administrative')
      users = all_org_users
    else
      users = @project.project_users.map{|p|p.user}.compact.collect {|i| [ ((i.id==@current_user.id ? 'me' : (i.full_name.present? ? i.full_name : i.email))), i.id ]}
    end
    render json: {:status => "success", :users=> users}
  end
  def change_project_status
    begin
      status = @current_organization.project_stages.find_by_name(params[:status])
      project = @current_organization.projects.find_by_id(params[:project_id])

      project.update_attribute :project_stage_id, status.id
      params[:user_id] = params[:user_id]=="All" ? "" : params[:user_id]
      @project_statuses = @current_organization.project_stages
      render :text => "Project Stage changed successfully!"  #partial: "get_kanban_view"
    rescue => ex
      render :text => ex.message
    end
  end
  def bulk_project_upload
    
    is_valid = false
    if params[:attachment_project].present?
      CSV.foreach(params[:attachment_project].path, headers: true, encoding: 'ISO-8859-1') do |row|
        fields_to_insert = %w{ organization_id user_id name short_name start_date end_date opportunity contact_email estimate_hour default_job_type description team_emails is_completed stage}
        rows_to_insert = []
        row['organization_id']=current_user.organization.id
        row['user_id'] = current_user.id
          row_to_insert = row.to_hash.select { |k, v| fields_to_insert.include?(k) }
          rows_to_insert << row_to_insert
          
          unless row['name'].nil? || row['name'].blank?
            TempProject.create! rows_to_insert
          end
          is_valid = true
        
      end      
    end
    respond_to do |format|
      format.text { render text: is_valid ? "success" : "error" }
    end
  
  end
  def destroy_temp_project
    
    TempProject.where(:id=>params[:id]).first.destroy
    respond_to do |format|
      format.text { render text: "success" }
    end
  end
  def destroy_all_temp_project
    TempProject.where(:user_id=>current_user.id).destroy_all
    respond_to do |format|
      format.text { render text: "success" }
    end
  end
  def project_preview
    @projects = TempProject.by_user current_user.id
  end
  def get_project_stages
    data = @current_organization.project_stages
    respond_to do |format|
      format.html 
      format.json { render json: data.map{|ps|{value: ps.name,text:ps.name} }}
    end
  end
  def get_project_job_types
    data = @current_organization.project_job_types
    respond_to do |format|
      format.html 
      format.json { render json: data.map{|ps|{value: ps.name,text:ps.name} }}
    end
  end
  def save_project_data
    @c = []

    lead = TempProject.find params[:name]
    if params[:pk] == "1"
      lead.update_column :name, params[:value]
      msg = "success"
    elsif params[:pk] == "2"
      lead.update_column :short_name, params[:value]
      msg = "success"
    elsif params[:pk] == "3"
      lead.update_column :start_date, params[:value]
    elsif params[:pk] == "4"
      lead.update_column :end_date, params[:value]
    elsif params[:pk] == "5"
      lead.update_column :opportunity, params[:value]
    elsif params[:pk] == "6"
      lead.update_column :contact_email, params[:value]
    elsif params[:pk] == "7"
      lead.update_column :estimate_hour, params[:value]
    elsif params[:pk] == "8"
      lead.update_column :default_job_type, params[:value]
    elsif params[:pk] == "9"
      lead.update_column :description, params[:value]
    elsif params[:pk] == "10"
      lead.update_column :team_emails, params[:value]
    elsif params[:pk] == "11"
      lead.update_column :is_completed, params[:value]
    elsif params[:pk] == "12"
      lead.update_column :stage, params[:value]
    
    end
    if (params[:pk].present? && !@c.include?(params[:value]))
      msg = "error_#{lead.id}"
    else
      msg = "success_#{lead.id}"
    end
    respond_to do |format|
   
      format.text { render text: msg }
    
    end
  end
  def save_projects
    temp_projects = TempProject.by_user current_user.id
    msg = []
    temp_projects.each do |tp|
      existing_prj=Project.where(:short_name => tp.short_name , :organization_id=> @current_organization.id ).first
      if(existing_prj.present?)
        msg << "Project with " + tp.short_name + " already exists!"
        next
      else
        prj = Project.new
        prj.name= tp.name
        prj.short_name= tp.short_name
        prj.start_date= tp.start_date
        prj.end_date= tp.end_date
        prj.estimate_hour= tp.estimate_hour
        prj.created_by= current_user
        prj.status= "Started"
        prj.description= tp.description
        deal = @current_organization.deals.where(:title=> tp.opportunity).first
        if(deal.present?)
          prj.deal_id= deal.id
        end
        prj.organization_id= @current_organization.id
        ic = @current_organization.individual_contacts.where(:email=>  tp.contact_email).first
        if(ic.present?)
          prj.individual_contact_id= ic.id
        end
       
        tasktype = @current_organization.project_task_types.where(:name=> tp.default_job_type).first
        if(tasktype.present?)
          prj.project_task_type_id= tasktype.id
        end
        prj.is_completed= tp.is_completed
        prj.is_archive= false
        prj.is_accessible= true
        prj.created_by=current_user
        projectstage = @current_organization.project_stages.where(:name=>  tp.stage).first
        if(projectstage.present?)
          prj.project_stage_id= projectstage.id
        end
        if tp.team_emails.present?
          team_emails = tp.team_emails.split("~")
          team_emails.each do |temail|
            tuser = @current_organization.users.where(:email=>temail).first
            prj.project_users.build({:user_id=>tuser.id})
          end   
        end
        
        if(prj.save)
          Activity.create(:organization_id => @project.organization_id, :activity_user_id => prj.created_by, :activity_type => @project.class.name, :activity_id => @project.id, :activity_status => "Create", :activity_desc => @project.name, :activity_date => @project.created_at, :is_public => true, :source_id => @project.id,:source_type=>@project.class.name)
        
          tp.destroy
        else
          msg << prj.errors.full_messages
        end
      end
    end
    if(msg.length > 0)
      flash[:notice] = msg.join("<br>")
    end
    redirect_to projects_kanban_path
  end
  # update project manager
  def update_project_manager
    project_id = params[:pk]
    project = Project.where(:id=>project_id, :organization_id=>@current_user.organization_id).first
    project.update_attribute :project_manager_id, params[:value]
    render :text=>"success"
  end
  # change project status from project details page.
  def change_proj_stage_from_details
    @project = @current_organization.projects.find(params[:id])
    proj_status = @current_organization.project_stages.where("id =?", params[:stage_id]).first
    if proj_status.name.present?
      @project.update_column(:project_stage_id, params[:stage_id])
      Activity.create(:organization_id => @project.organization_id, :activity_user_id => @current_user.id, :activity_type => @project.class.name, :activity_id => @project.id, :activity_status => "Status Changed", :activity_desc => "Changed project status to #{@project.project_stage.name}", :activity_date => @project.updated_at, :is_public => true, :source_id => @project.id,:source_type=>@project.class.name)
    end
    render partial: "project_status_bar"

  end
  #Project widget in project details
  def project_widget
    @project = @current_organization.projects.where("id=?", params[:id]).first
    if params[:tab_type] == "quick_notes"
      query_condition=[]
      query_condition.where("projects.id = ? and projects.organization_id=?", params[:id], @current_organization.id)
      org_notes = @current_organization.notes.where(notable_type: "Project", notable_id: params[:id]).order("created_at desc")
      @notes=[]
      org_notes.each do |note|
        @notes << note if note.title.present?
      end
      @note = Note.new()
      unless @current_user.is_admin? || @current_user.is_super_admin?
        query_condition.where("projects.created_by=?", @current_user.id)
      end
      render partial: "project_quick_notes"
    elsif params[:tab_type] == "activity_stream"
      render partial: "time_line_stream"
    elsif params[:tab_type] == "emails"
      @emails = @project.mail_letters.order("id DESC")
      render partial: "project_emails"
    elsif params[:tab_type] == "invoices"
      @deal = @project.deal
      @contact = @deal.deals_contacts.first.contactable
      @invoices = @project.invoices.where(invoice_type: "invoice").order("created_at desc")
      render partial: "project_invoices"
    elsif params[:tab_type] == "files"
      project_notes = @current_organization.notes.where(notable_type: "Project", notable_id: params[:id]).order("created_at desc")
      @notes=[]
      project_notes.each do |note|
        @notes << note if note.note_attachments.present?
      end
      if (project_jobs = @project.project_jobs).present?
        project_jobs.each do |pj|
          project_job_notes = @current_organization.notes.where(notable_type: "ProjectJob", notable_id: pj.id).order("created_at desc")
          project_job_notes.each do |note|
            @notes << note if note.note_attachments.present?
          end
        end
        project_jobs.each do |pj|
          pj.comments.each do |comment|
           if comment.note.present?
              comment.note.each do |n|
                @notes << n if n.note_attachments.present?
              end
           end
          end
        end
      end
      
      @note = Note.new()
      render partial: "files"
    else
      render text:"Some error has been occured, please contact to support."
    end
  end
  def get_project_dependent_data
    project = Project.where(:id=>params[:id]).first
    project_users = project.project_users.map{|u| u.user}
    if(project.project_type == 'Administrative')
      project_users = all_org_users
    end
    #[u.user.id,u.user.full_name.present? ? u.user.full_name : u.user.email]
    # p project.project_job_groups
    project_job_groups = project.project_job_groups.collect{|u| {id:u.id,name:u.name}}
    # p project_job_groups
    # puts "nw users .............."
    # p project_users.collect{|pu| [pu.id,pu.email]  if pu.present?}
    

    p project.project_type
    render :json=>{status: "success", project_users: project_users.collect{|pu| {id: pu.id,name: pu.full_name.present? ? pu.full_name : pu.email} if pu.present?}, project_job_groups: project_job_groups,:project_type => project.project_type}
  end
  private
  def set_project
    @project = Project.find(params[:id])
  end
end

class FilesController < ApplicationController
  def index
    if @current_user.is_admin?
      @note_attachments = @current_organization.all_attachments
    else
      flash[:bodanger] = "You don't have sufficient permission to view this page."
      redirect_to root_path
    end
  end
  def get_all_leads
    @deals = @current_organization.deals.order("title asc")
    render partial: "get_all_leads"
  end
  def filter_files_by_lead
    notes = @current_organization.notes.where(notable_type: "Deal", notable_id: params[:id])
    @deal = @current_organization.deals.find(params[:id])
    @note_attachments = @current_organization.all_attachments notes
    render partial: "show_files"
  end

  def get_all_projects
    @projects = @current_organization.projects.order("name asc")
    render partial: "get_all_projects"
  end
  def filter_files_by_project
    @project = @current_organization.projects.where("id = ?",params[:id]).first
    
    comments_id = @project.project_jobs.map{|j| j.comments}.flatten.collect { |obj| obj.id }
    notes = @current_organization.notes.where("notable_type=? AND notable_id IN(?)", "Comment", comments_id)

    @note_attachments = @current_organization.all_attachments notes
    render partial: "show_files"
  end

  def load_all_files
    @note_attachments = @current_organization.all_attachments
    render partial: "show_files"
  end
  def filter_file_on_date_range
    notes = @current_organization.notes.where(created_at: params[:from_date]..params[:to_date])
    @note_attachments = @current_organization.all_attachments notes
    render partial: "show_files"
  end
  def get_all_users
    @users = @current_organization.users.order("first_name asc")
    render partial: "get_all_users"
  end
  def filter_files_by_user
    notes = @current_organization.notes.where(created_by: params[:user_id])
    @user = @current_organization.users.find(params[:user_id])
    @note_attachments = @current_organization.all_attachments notes
    render partial: "show_files"
  end
  def archive_selected_files
    p "---------------#{params[:attachment_to_delete]}"
    @note_attachments = @current_organization.all_attachments.where("id IN(?)",params[:attachment_to_delete].split(","))
    @note_attachments.each do |n|
      n.update_attributes :is_archive => true
    end
    flash[:notice] = "Your files(s) has been deleted."
    redirect_to "/files"
  end
  def download_file
    note_attachment = NoteAttachment.where("id=?",params[:id]).first
    if note_attachment.present?
      send_file(
      open(note_attachment.attachment.url),
      filename: note_attachment.attachment_file_name,
      type: "image/#{note_attachment.attachment_file_name.split('.').last()}"
    )
    end
  end
end

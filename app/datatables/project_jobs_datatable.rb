require "will_paginate/array"
class ProjectJobsDatatable
  include ApplicationHelper
  include ProjectJobsHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: project_jobs.count,
      iTotalDisplayRecords: project_jobs.total_entries,
      aaData: data
    }
  end

private

  def data
    i=0
    project_jobs.map do |project_job|
      [
        h(project_job.job_no.present? ? project_job.job_no : "" ),#row[0]
        h(project_job.id),#row[1]
        h(project_job.name),#row[2]
        h(project_job.project.present? && project_job.project.deal.present? ? project_job.project.deal.title : "NA"),#row[3]
        h(project_job.project.present? && project_job.project.deal.present? ? 
            (project_job.project.deal.deals_contacts.first.contactable.present? && project_job.project.deal.deals_contacts.first.contactable.full_name.present? ? 
                project_job.project.deal.deals_contacts.first.contactable.full_name : project_job.project.deal.deals_contacts.first.contactable.present? ? project_job.project.deal.deals_contacts.first.contactable.email : "NA") : "NA"),
        h(project_job.description),#row[5]
        h(project_job.priority),#row[6]
        h(project_job.updated_at.strftime("%b %d, %Y @ %H:%M %P")),#row[7]
        h(project_job.status),#row[8]
        h(project_job.due_date.present? ? project_job.due_date.strftime("%m/%d/%Y") : "NA"),#row[9] # ("%b %d,%a")
        h(project_job.project.id),#row[10]
        h(project_job.user_responsible.present? ? (project_job.user_responsible.full_name.present? ? project_job.user_responsible.full_name : project_job.user_responsible.email) : ""), #row[11]
        h(params[:by_group_name].present? && params[:by_group_name] == "true" ? (project_job.project_job_group.present? ? project_job.project_job_group.name : "Default Job Group") : project_job.created_at.strftime("%b %d")), #row[12]
        h(project_job.created_user.full_name.present? ? project_job.created_user.full_name : project_job.created_user.email),  #row[13]
        h(project_job.created_at.strftime("%b %d, @ %H:%M %P")), #row[14]
        h(project_job.project.present? && project_job.project.deal.present? ? project_job.project.deal.to_param : ""),#row[15]
        h(project_job.individual_contact.present? ? (project_job.individual_contact.to_param) : ""),#row[16]
        h(project_jobs.total_entries), #row [17]
        h(project_job.due_date.present? ? project_job.due_date.strftime("%m %d, %Y @ %H,%M") : ""), #row [18]
        h(project_job.resolved_at), #row [19]
        h(project_job.closed_at), #row [20]
        h(project_job.project_stage.name) #row [21]
      ]
    end
  end
  
  def project_jobs
    @project_jobs ||= fetch_project_jobs
  end

  def fetch_project_jobs
    cuser=User.find_by_id params[:cuser]
    filtervalue = params[:filtervalue]
    filtertype = params[:filtertype]
    cre_by = params[:cre_by]
    cre_by_val = params[:cre_by_val]
    asg_by = params[:asg_by]
    asg_by_val = params[:asg_by_val]
    daterange = params[:daterange]
    dt_range = params[:dt_range]
    stage = params[:status]
    stage_val = params[:status_val]
    proj_stage_val = params[:proj_stage_val]
    project=cuser.organization.projects.where("id=?",params[:project_id]).first
    project_jobs = []
    p params
    p active_multifilter?
    puts ">>>>.....................................ative filter is found or not"
    if active_multifilter?
      puts "coming to active_multifilter???????????????????????????????????"
      params[:assigned_to]=nil
      params[:created_by]=nil
      project_jobs = project.project_jobs.includes(:assigned_user).active_multi_filter(params)
    else
      if params[:status].present? && params[:status] != "calendar"
        project_jobs = project.project_jobs.includes(:assigned_user).job_list(project, params[:status]).page(page).per_page(per_page)
      else
        project_jobs = project.project_jobs.includes(:assigned_user)
      end
    end

    case params[:page_tab]
    when "all"
      project_jobs = project_jobs
      order_by="due_date DESC"
    when "today"
      project_jobs = project_jobs.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
      p project_jobs.count
      order_by="due_date ASC"
    when "overdue"
      project_jobs = project_jobs.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ?", false, Time.zone.now.strftime("%Y/%m/%d"))
      order_by="due_date ASC"
    when "upcoming"
      project_jobs = project_jobs.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", false, Time.zone.now.strftime("%Y/%m/%d"))
      order_by="due_date ASC"
    when "completed"
      project_jobs = project_jobs.where("is_completed=?", true)
      order_by="due_date DESC"
    end

    project_jobs = project_jobs.page(page).per_page(per_page)
      
    if params[:sSearch].present?
      project_jobs = project_jobs.where("(title like :search)", search: "%#{params[:sSearch]}%")
    end
    project_jobs.order("#{sort_column} #{sort_direction}")
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[job_no id name name name name priority updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  private
  def active_multifilter?
    params[:cre_by].present? || params[:cre_by_val].present? || params[:asg_by].present? || params[:asg_by_val].present? || params[:loc].present? || params[:loc_val].present? || params[:priority].present? || params[:priority_val].present?|| params[:proj].present? || params[:proj_val].present? || params[:daterange].present? || params[:dt_range].present? || params[:last_touch].present? || params[:last_tch].present?  || params[:dt_range_from].present? || params[:dtrange_from].present? || params[:dtrange_to].present? || params[:dt_range_to].present? || params[:is_opportunity].present? || params[:tag].present? || params[:status].present? || params[:status_val].present? || params[:proj_stage].present? || params[:proj_stage_val].present?
  end
end

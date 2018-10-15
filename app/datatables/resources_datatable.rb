require "will_paginate/array"
class ResourcesDatatable
  include ApplicationHelper
  include ProjectJobsHelper
  include ActionView::Helpers::DateHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords:  resources.count ,
      iTotalDisplayRecords:  resources.total_entries,
      aaData: data
    }
  end

private

  def data
    i=0
    resources.map do |jtl|
        [
          # h(i+=1),#row[0]
          h(jtl.log_start_time.strftime("%m/%d/%Y")),
          h(jtl.user.full_name.present? ? jtl.user.full_name : jtl.user.email),
          h(jtl.project_job.present? && jtl.project_job.project.present? ? jtl.project_job.project.name : "") ,
          h(jtl.project_job.present? ? jtl.project_job.name : ""),
          h(jtl.project_job.present? ? jtl.project_job.estimate_hour.to_s + " hrs" : ""),
          h(getHourMinuteFromSeconds(jtl.spent_hours) + " hrs"),
          h(jtl.is_billable),
          h(jtl.project_job.present? ? jtl.project_job.status : "Archived"),
        ]
      
    end
  end
  
 
  def resources
    p @prms
    @resource_utilizations ||= fetch_resource_utilizations
  end

  def fetch_resource_utilizations
    cuser=User.find_by_id params[:cuser]
    # filtervalue = params[:filtervalue]
    # filtertype = params[:filtertype]
    # stage = params[:status] 
    project_id = params[:project_id]
    user_id = params[:user_id]
    from_log_date = params[:from_log_date]
    to_log_date=params[:to_log_date]
    #projects=cuser.organization.projects
    # resource_utils = JobTimeLog.includes({:project_job=>:project},:user)
    resource_utils = cuser.organization.job_time_logs.includes({:project_job=>:project},:user)
    if(project_id.present?)
      resource_utils = resource_utils.where("project_jobs.project_id = #{project_id}")
    end
    if(user_id.present?)
      resource_utils = resource_utils.where("job_time_logs.user_id = #{user_id}")
    end
    if(from_log_date.present?)
      resource_utils = resource_utils.where("DATE(job_time_logs.log_start_time) >= '#{Date.strptime(from_log_date,"%m/%d/%Y")}'")
    end
    if(to_log_date.present?)
      resource_utils = resource_utils.where("DATE(job_time_logs.log_start_time) <= '#{Date.strptime(to_log_date,"%m/%d/%Y")}'")
    end
    if params[:sSearch].present?
      resource_utils = resource_utils.where("(project_jobs.name like :search or users.first_name like :search or projects.name like :search)", search: "%#{params[:sSearch]}%")
    end
    
    resource_utils = resource_utils.order("#{sort_column} #{sort_direction}")
    resource_utils = resource_utils.page(page).per_page(per_page)
   resource_utils
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[log_end_time job_time_logs.user_id project_jobs.project_id project_jobs.name project_jobs.estimate_hour job_time_logs.spent_hours job_time_logs.is_billable project_jobs.status]
    p columns[params[:iSortCol_0].to_i]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  private
  # def active_multifilter?
  #   params[:cre_by].present? || params[:cre_by_val].present? || params[:asg_by].present? || params[:asg_by_val].present? || params[:lead].present? || params[:lead_val].present? || params[:daterange].present? || params[:dt_range].present? || params[:last_touch].present? || params[:last_tch].present?  || params[:dt_range_from].present? || params[:dtrange_from].present? || params[:dtrange_to].present? || params[:dt_range_to].present? || params[:status].present? || params[:status_val].present?
  # end
end

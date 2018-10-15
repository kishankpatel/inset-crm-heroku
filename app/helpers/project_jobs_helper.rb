module ProjectJobsHelper

  def project_job_all
      project_jobs=@project.project_jobs if @project.present? && @project.project_jobs.present?

    if project_jobs
        project_jobs = project_jobs
        project_jobs=project_jobs.where("(project_jobs.assigned_to=? )", current_user.id) unless current_user.is_admin?
        project_jobs.count
    end
  end
  def project_job_today
      project_jobs=@project.project_jobs if @project.present? && @project.project_jobs.present?

    if project_jobs
      project_jobs=project_jobs.where("project_jobs.is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
     
        project_jobs=project_jobs.where("(project_jobs.assigned_to=?)", current_user.id) unless current_user.is_admin?
        project_jobs.count
    end  
  end

  def project_job_overdue
      project_jobs=@project.project_jobs if @project.present? && @project.project_jobs.present?
    if project_jobs
        project_jobs=project_jobs.where("project_jobs.is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') < ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
        project_jobs=project_jobs.where("(project_jobs.assigned_to=?)", current_user.id) unless current_user.is_admin?
        project_jobs.count
    end  
  end

   def project_job_upcoming
      project_jobs=@project.project_jobs if @project.present? && @project.project_jobs.present?
    if project_jobs
        project_jobs=project_jobs.where("project_jobs.is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
        project_jobs=project_jobs.where("(project_jobs.assigned_to=? )", current_user.id) unless current_user.is_admin?
        project_jobs.count
     end
  end

  def project_job_completed
    project_jobs=@project.project_jobs if @project.present? && @project.project_jobs.present?
    if project_jobs
        project_jobs = project_jobs.where("project_jobs.is_completed=? ", true)
        project_jobs=project_jobs.where("(project_jobs.assigned_to=?)", current_user.id) unless current_user.is_admin?
        project_jobs.count
    end
  end
  def getHourMinuteFromSeconds(seconds)
    hours = seconds / 3600;
    minutes = (seconds % 3600) / 60
    return (hours <= 9 ? "0" + hours.to_s : hours.to_s) + ":" + (minutes <= 9 ? "0" + minutes.to_s : minutes.to_s)
  end
  def getHourMinuteFromMinutes(minutes)
    return ((minutes / 60) < 10 ? "0" : "") +  (minutes / 60).to_s + ":" + ((minutes % 60) < 10 ? "0" : "") + (minutes % 60).to_s if minutes.present?
  end
  def get_project_status_color_class status
    case status
      when "New"
        " btn btn-outline btn-success"
      when "In Progress"
        " btn btn-outline btn-warning"
      when "Resolved"
        " btn btn-outline btn-info"
      when "Blocked"
        " btn btn-outline btn-danger"
      when "Closed"
        " btn btn-primary2 btn-danger"
    end

  end
  def get_project_status_panel_class status
    case status
      when "New"
        " hgreen"
      when "In Progress"
        " hyellow"
      when "Resolved"
        " hblue"
      when "Blocked"
        " hred"
      when "Closed"
        " hviolet"
    end

  end
end

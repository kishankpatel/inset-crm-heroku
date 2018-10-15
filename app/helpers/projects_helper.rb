module ProjectsHelper

	def  overdue_jobs project
		project_jobs=project.project_jobs.where("project_jobs.is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
		project_jobs=project.project_jobs.where("(project_jobs.assigned_to=? )", current_user.id) unless current_user.is_admin?
		project_jobs.count
	end
	def upcoming_jobs project
		project_jobs=project.project_jobs.where("project_jobs.is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ? ", false, Time.zone.now.strftime("%Y/%m/%d"))
		project_jobs=project.project_jobs.where("(project_jobs.assigned_to=? )", current_user.id) unless current_user.is_admin?
  		project_jobs.count
  end
  def lead_name project
    if project.deal.present? && project.deal.deals_contacts.present?
      project.deal.deals_contacts.first.contactable.present? ? project.deal.deals_contacts.first.contactable.full_name.present? ? project.deal.deals_contacts.first.contactable.full_name : project.deal.deals_contacts.first.contactable.email : 'N/A'
    end
  end
  def deactivated_by project
    user = project.organization.users.where( id: project.deal.deactivated_by).first
    user.full_name.present? ? "#{user.full_name}(#{user.email})" : user.email
  end
  def get_project_activity_stream project
    #activities = project.activities.where("organization_id = ?", current_user.organization.id).order("activity_date desc")
    activities = []
    activities << @current_organization.activities.order("created_at desc").where("activity_type=? AND source_id=?", "Project",project.id)
    if project.project_jobs.present?
      project.project_jobs.each do |pj|
        activities << @current_organization.activities.order("created_at desc").where("activity_type=? AND source_id=?", "ProjectJob",pj.id)
      end
    end
    activities.flatten
  end
end

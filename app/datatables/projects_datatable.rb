require "will_paginate/array"
class ProjectsDatatable
  include ApplicationHelper
  include ProjectsHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: projects.count,
      iTotalDisplayRecords: projects.total_entries,
      aaData: data
    }
  end

private

  def data
    i=0
    puts "coming to dta in projects......................"
    begin
      projects.map do |project|
        [
          h(i+=1),#row[0]
          h(project.id),#row[1]
          h(project.name),#row[2]
          h(project.individual_contact.present? ? link_to(project.individual_contact.name.truncate(20), "/contact/"+project.individual_contact.to_param, :title => project.individual_contact.name, :class=>"change-color-ll") : ""),#row[3]
          h(project.deal.present? ? ( project.deal.is_active ? link_to(project.deal.title.truncate(20), "/leads/"+project.deal.to_param, :title => project.deal.title, :class=>"change-color-ll") : link_to(project.deal.title.truncate(25), "javascript:void(0)", :title => "Sorry!! The respective opportunity linked with Lead, '#{lead_name(project)}' has been deleted by '#{deactivated_by(project)}'.", :class=>"change-color-ll", style:"color:#999;cursor:not-allowed;text-decoration:none;") ) : ""),#row[4]
          h(project.description.present? ? project.description : "NA"),#row[5]
          h(project.project_users.map{|p|p.user}.compact.count),#row[6]
          h(project.project_jobs.count),#row[7]
          h(project.status),#row[8]
          h(project.updated_at.strftime("%b %d, %Y @ %H:%M %P")),#row[9]
          h(project.created_user.present? ? (project.created_user.full_name.present? ? project.created_user.full_name : project.created_user.email) : ""), #row[10]
          h(project.created_at.strftime("%b %d, @ %H:%M %P")),#row[11]
          h(project.deal.present? ? project.deal.to_param : ""),#row[12]
          h(project.individual_contact.present? ? project.individual_contact.to_param : ""), #row[13]
          h(project.is_completed), #row[14],
          h(project.project_manager.present? ? (project.project_manager.full_name.present? ? project.project_manager.full_name : project.project_manager.email) : ""), #row[15]
          h(project.linked_with), #row[16]
          h(project.company_contact.present? ? link_to(project.company_contact.name.truncate(20), "/company_contact/"+project.company_contact.to_param, :title => project.company_contact.name, :class=>"change-color-ll") : ""),#row[17]
          h(project.project_type),#row[18]
        ]
      end
    rescue => ex
      puts ex.message
      #puts ex.backtrace("\n")
    end
  end
  
  # def lead_name project
  #   if project.deal.present? && project.deal.deals_contacts.present?
  #     project.deal.deals_contacts.first.contactable.full_name.present? ? project.deal.deals_contacts.first.contactable.full_name : project.deal.deals_contacts.first.contactable.email
  #   end
    
  # end
  # def deactivated_by project
  #   user = project.organization.users.where( id: project.deal.deactivated_by).first
  #   user.full_name.present? ? "#{user.full_name}(#{user.email})" : user.email
  # end

  def projects
    @projects ||= fetch_projects
  end

  def fetch_projects
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

    #projects=cuser.organization.projects
    projects = []

    if active_multifilter?
      params[:assigned_to]=nil
      params[:proj_created_by]=nil
      projects = cuser.organization.projects.active_multi_filter(params)
    else
      projects = cuser.organization.projects
    end
    #if projects.present?
      projects = projects.includes(:deal,:individual_contact,:company_contact,:project_manager).page(page).per_page(per_page)
      if params[:sSearch].present?
        projects = projects.where("(title like :search)", search: "%#{params[:sSearch]}%")
      end
    #end
    projects.order("created_at desc")
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  private
  def active_multifilter?
    params[:cre_by].present? || params[:cre_by_val].present? || params[:asg_by].present? || params[:asg_by_val].present? || params[:lead].present? || params[:lead_val].present? || params[:daterange].present? || params[:dt_range].present? || params[:last_touch].present? || params[:last_tch].present?  || params[:dt_range_from].present? || params[:dtrange_from].present? || params[:dtrange_to].present? || params[:dt_range_to].present? || params[:status].present? || params[:status_val].present?
  end
end

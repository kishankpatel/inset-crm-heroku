  class ListCompaniesDatatable
  include ApplicationHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: companies.count,
      iTotalDisplayRecords: companies.total_entries,
      aaData: data
    }
  end

private

  def data
    companies.map do |company|
      [
        h(company.id), #row[0]
        h(company.name), #row[1]
        h(company.individual_contacts.present? ? company.individual_contacts.first.name : ""),  #row[2]
        # h(company.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten.select{|d| d.is_active}.count), #row[3]
        h(company.total_opportunities), #row[3]
        h(company.individual_contacts.count), #row[4]
        h(company.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten.map{|d|d.tasks}.compact.flatten.count), #row[5]
        h(company.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten.map{|d|d.tasks}.compact.flatten.map{|t|t.user}.compact.uniq.count), #row[6]
        h(company.to_param), #row[7]
        h(company.get_location.present? ? company.get_location : "NA"), #row[8]
        # h(company.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten.select{|d| (d.is_won == nil || d.is_won == "") && d.is_active}.count), #row[9]
        h(company.total_open_opportunities), #row[9]
        h(company.initiator.present? ? (company.initiator.full_name.present? ? company.initiator.full_name : company.initiator.email ) : ""), #row[10]
        h(company.created_at.strftime("%b %d,%Y")) #row[11]
      ]
    end
  end
  
  def companies
    @sources ||= fetch_companies
  end

  def fetch_companies
    org = Organization.find_by_id params[:org]
    user = org.users.find_by_id params[:user_id]
    if user.is_admin?
      companies = org.company_contacts
    else
      companies = org.company_contacts.where("created_by=?",user.id)
    end
    companies = companies.order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    if params[:sSearch].present?
      companies = companies.where("(name like :search)", search: "%#{params[:sSearch]}%")
    end
    companies
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 12
  end

  def sort_column
    columns = %w[name id total_opportunities id id created_at total_open_opportunities]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

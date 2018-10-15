class AllContactsDatatable
  include ApplicationHelper
  include ContactsHelper
  include ActionView::Helpers::DateHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords:  contacts.count ,
      iTotalDisplayRecords:  contacts.total_entries,
      aaData: data
    }
  end

private
  def data
    # Display each record of IndividualContact and CompanyContact in datatable
    contacts.map do |con|
      
      if con.contact_type == "IndividualContact"
        to_param_id = con.to_param
        deals_contacts = con.deals_contacts
        country = con.company_contact.present? ? ((con.company_contact.address.present? && con.company_contact.address.country.present?) ? con.company_contact.address.country.name : "") : (con.country.present? ? con.country.name : "")
        ph = con.phones.present? ? con.phones.by_phone_type("work") : nil
      else
        to_param_id =  con.to_class_param(CompanyContact.encrypted_id_key, con.id)
        deals_contacts = nil
        country = CompanyContact.get_org_location(con.id)
        ph = CompanyContact.get_phone(con.id)
      end
      total_opportunities = con.total_opportunities
      if con.class.name == "IndividualContact"
        cont_type = "individual"
      else
        cont_type = "company"
      end
      # Find last touch of the Individual or Company contact.
      activ_date = show_contact_last_activity(con.id,"#{cont_type}")[0] if con.present?
      activ_by = show_contact_last_activity(con.id,"#{cont_type}")[1] if con.present?
      if( activ_by.present? && activ_date.present? )
        last_touch = "#{activ_date} ago * by #{activ_by}"
      else
        last_touch = "No Activity Found"
      end
      cuser =User.find params[:cuser]

      if cont_type == "individual"
        [
          h(to_param_id), #row[0]
          h(con.contact_type == "IndividualContact" ? "individual_contact" : "company"), #row[1]
          h(con.first_name.present? ? con.first_name[0].upcase : (con.email.present? ? con.email[0].upcase : "") ), #row[2]
          h(con.full_name.present? ? con.full_name : con.email), #row[3]
          h(con.email.present? ? con.email : "NA"), #row[4]
          h(con.company_contact.present? ? con.company_contact.name : "NA"), #row[5]
          h(country), #row[6]
          h(ph.present? && ph.first.phone_no.present? ? ph.first.phone_no : ""), #row[7]
          h(con.website.present? ? con.website : ""), #row[8]
          h(Contact.get_color_code(con.first_name.present? ? con.first_name.downcase[0] : (con.email.present? ? con.email.downcase[0] : ""))), #row[9]
          h(con.class.name), #row[10]
          h(con.image.present? ? con.image.image.url(:icon) : ""), #row[11]
          h(con.company_contact.present? ? ("/company_contact/"+con.company_contact.to_param) : "javascript:void(0)"), #row[12]
          h(con.is_csv), #row[13]
          h(con.id), #row[14]
          h(con.contact_opportunity.present? ? con.contact_opportunity.opportunity : ""), #row[15]
          h(con.contact_opportunity.present? ? con.contact_opportunity.is_converted : ""), #row[16]
          h(con.contact_opportunity.present? ? con.contact_opportunity.deal.to_param : ""), #row[17]
          h(cuser.is_admin? ? true : false), #row[18]
          h(deals_contacts.present? ? deals_contacts.count : 0), #row[19]
          h(''), #row[20]
          h(''), #row[21]
          h(''), #row[22]
          h(''), #row[23]
          h(con.country.present? ? con.country.id : ""), #row[24]
          h(con.contact_type == "IndividualContact" ? con.get_type : 'Company'), #row[25]
          h(con.contact_type == "IndividualContact" ? (deals_contacts.map{|dc| dc.deal if dc.deal.present? && dc.deal.is_active && (dc.deal.is_won == "" || dc.deal.is_won == nil)}.compact.count) : con.total_open_opportunities), #row[26]
          h(con.contact_type), #row[27]
          h(''), #row[28]
          h(con.contact_type == "IndividualContact" ? con.get_project_count : CompanyContact.get_projects_count(con.id)) #row[29]
        ] 
      else
        [
          h(con.id), #row[0]
          h("company_contact"), #row[1]
          h(con.name.present? ? con.name[0].upcase : con.email[0].upcase), #row[2]
          h(con.name), #row[3]
          h(con.email.present? ? con.email : "NA"), #row[4]
          h("NA"), #row[5]
          h(con.country.present? ? con.country.name : "NA"), #row[6]
          h(ph.present? ? ph.first.phone_no : "NA"), #row[7]
          h(con.website.present? ? con.website : "NA"), #row[8]
          h(Contact.get_color_code(con.name.downcase[0])), #row[9]
          h(con.class.name), #row[10]
          h(con.image.present? ? con.image.image.url(:icon) : "") #row[11]
        ]
      end
    end
  end
  # Get all Individual and Company Contact.
  def contacts
    @contacts ||= fetch_contacts
  end
  # Fetch all Individual and Company Contact.
  def fetch_contacts 
    cuser = User.find params[:cuser]
    corganization = cuser.organization

    if !cuser.is_admin?
      if params[:sSearch].present?
        all_contacts = IndividualContact.find_by_sql("select * from (
        (select id,'IndividualContact' as contact_type, created_at, updated_at, created_by, first_name, last_name, email, country_id, website, is_csv, 0 as total_open_opportunities, 0 as total_opportunities from individual_contacts where organization_id = #{corganization.id} AND is_archive = false AND created_by = #{cuser.id} AND (first_name like '%#{params[:sSearch]}%' or last_name like '%#{params[:sSearch]}%' or email like '%#{params[:sSearch]}%'))
        UNION ALL
        (select id, 'CompanyContact' as contact_type, created_at, updated_at, created_by, name as first_name, '' as last_name, email, null as country_id, website, 0 as is_csv, total_open_opportunities, total_opportunities from company_contacts where organization_id = #{corganization.id} AND is_archive = false AND created_by = #{cuser.id} AND (name like '%#{params[:sSearch]}%' or email like '%#{params[:sSearch]}%'))
        ) contacts order by #{sort_column} #{sort_direction}")
      else
        all_contacts = IndividualContact.find_by_sql("select * from (
        (select id,'IndividualContact' as contact_type, created_at, updated_at, created_by, first_name, last_name, email, country_id, website, is_csv, 0 as total_open_opportunities, 0 as total_opportunities from individual_contacts where organization_id = #{corganization.id} AND is_archive = false AND created_by = #{cuser.id})
        UNION ALL
        (select id, 'CompanyContact' as contact_type, created_at, updated_at, created_by, name as first_name, '' as last_name, email, null as country_id, website, 0 as is_csv, total_open_opportunities, total_opportunities from company_contacts where organization_id = #{corganization.id} AND is_archive = false AND created_by = #{cuser.id})
        ) contacts order by #{sort_column} #{sort_direction}")
      end
    else
      if params[:sSearch].present?
        all_contacts = IndividualContact.find_by_sql("select * from (
        (select id,'IndividualContact' as contact_type, created_at, updated_at, created_by, first_name, last_name, email, country_id, website, is_csv, 0 as total_open_opportunities, 0 as total_opportunities from individual_contacts where organization_id = #{corganization.id} AND is_archive = false AND (first_name like '%#{params[:sSearch]}%' or last_name like '%#{params[:sSearch]}%' or email like '%#{params[:sSearch]}%'))
        UNION ALL
        (select id, 'CompanyContact' as contact_type, created_at, updated_at, created_by, name as first_name, '' as last_name, email, null as country_id, website, 0 as is_csv, total_open_opportunities, total_opportunities from company_contacts where organization_id = #{corganization.id} AND is_archive = false AND (name like '%#{params[:sSearch]}%' or email like '%#{params[:sSearch]}%'))
        ) contacts order by #{sort_column} #{sort_direction}")
      else
        all_contacts = IndividualContact.find_by_sql("select * from (
        (select id,'IndividualContact' as contact_type, created_at, updated_at, created_by, first_name, last_name, email, country_id, website, is_csv, 0 as total_open_opportunities, 0 as total_opportunities from individual_contacts where organization_id = #{corganization.id} AND is_archive = false)
        UNION ALL
        (select id, 'CompanyContact' as contact_type, created_at, updated_at, created_by, name as first_name, '' as last_name, email, null as country_id, website, 0 as is_csv, total_open_opportunities, total_opportunities from company_contacts where organization_id = #{corganization.id} AND is_archive = false)
        ) contacts order by #{sort_column} #{sort_direction}")
      end
    end
    all_contacts.paginate(:page => page, :per_page => per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 20
  end

  def sort_column
    columns = %w[first_name first_name email]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "asc" ? "asc" : "desc"
  end
end

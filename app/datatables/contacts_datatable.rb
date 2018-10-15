class ContactsDatatable
  include ApplicationHelper
  include ContactsHelper
  include ActionView::Helpers::DateHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    # cuser =User.find params[:cuser]
    # if cuser.is_super_admin?
    #   all_contacts = cuser.organization.individual_contacts.count #+ cuser.organization.company_contacts.count
    # else
    #   all_contacts = IndividualContact.where("created_by= ?", cuser.id).count #+ CompanyContact.where("created_by=?", cuser.id).count
    # end
    # {
    #   sEcho: params[:sEcho].to_i,
    #   iTotalRecords: all_contacts,
    #   iTotalDisplayRecords: all_contacts,
    #   aaData: data
    # }
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
    contacts.preload(:image).preload(:work_phones).preload(:deals_contacts=>:deal).preload(:company_contact=>:address).preload(:country).map do |con|
    
      if con.class.name == "IndividualContact"
        cont_type = "individual"
      else
        cont_type = "company"
      end
      ph = con.work_phones
      # ph = con.phones.by_phone_type "work"
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
          h(con.to_param), #row[0]
          h("individual_contact"), #row[1]
          h(con.first_name.present? ? con.first_name[0].upcase : (con.email.present? ? con.email[0].upcase : "") ), #row[2]
          h(con.full_name.present? ? con.full_name : con.email), #row[3]
          h(con.email.present? ? con.email : "NA"), #row[4]
          h(con.company_contact.present? ? con.company_contact.name : "NA"), #row[5]
          h(con.company_contact.present? ? (con.company_contact.address.present? && con.company_contact.address.country.present? ? con.company_contact.address.country.name : "") : (con.country.present? ? con.country.name : "")), #row[6]
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
          h(con.deals_contacts.present? ? con.deals_contacts.count : 0), #row[19]
          h(con.deals_contacts.present? && con.deals_contacts.map{|dc| dc.deal if (dc.deal.present? && !dc.deal.is_won.to_s.present? && dc.deal.is_active)}.compact.present? ? con.deals_contacts.map{|dc| dc.deal if (dc.deal.present? && !dc.deal.is_won.to_s.present? && dc.deal.is_active)}.compact.last.title.truncate(15) : ''), #row[20]
          h(con.deals_contacts.present? && con.deals_contacts.map{|dc| dc.deal if (dc.deal.present? && !dc.deal.is_won.to_s.present? && dc.deal.is_active)}.compact.present? ? con.deals_contacts.map{|dc| dc.deal if (dc.deal.present? && !dc.deal.is_won.to_s.present? && dc.deal.is_active)}.compact.last.to_param : ''), #row[21]
          h(con.deals_contacts.present? && con.deals_contacts.map{|dc| dc.deal if (dc.deal.present? && !dc.deal.is_won.to_s.present? && dc.deal.is_active)}.compact.present? ? con.deals_contacts.map{|dc| dc.deal if (dc.deal.present? && !dc.deal.is_won.to_s.present? && dc.deal.is_active)}.compact.last.title : ''), #row[22]
          h(con.deals_contacts.present? && con.deals_contacts.map{|dc| dc.deal if (dc.deal.present? && !dc.deal.is_won.to_s.present? && dc.deal.is_active)}.compact.present? ? con.deals_contacts.map{|dc| dc.deal if (dc.deal.present? && !dc.deal.is_won.to_s.present? && dc.deal.is_active)}.compact.count - 1 : ''), #row[23]
          h(con.country.present? ? con.country.id : ""), #row[24]
          h(con.get_type), #row[25]
          h(con.deals_contacts.map{|dc| dc.deal if dc.deal.present? && dc.deal.is_active && (dc.deal.is_won == "" || dc.deal.is_won == nil)}.compact.count) #row[26]
        ] 
      else
        [
          h(con.to_param),
          h("company_contact"),
          h(con.name.present? ? con.name[0].upcase : con.email[0].upcase),
          h(con.name),
          h(con.email.present? ? con.email : "NA"),
          h("NA"),
          h(con.country.present? ? con.country.name : "NA"),
          h(ph.present? ? ph.first.phone_no : "NA"),
          h(con.website.present? ? con.website : "NA"),
          h(Contact.get_color_code(con.name.downcase[0])),
          h(con.class.name),
          h(con.image.present? ? con.image.image.url(:icon) : "")
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
    cuser =User.find params[:cuser]

    if params[:tab].present? && params[:tab] == "all_contacts"
      puts "coming to all cotacts tab................................"
      if cuser.is_admin? 
        puts "coming to is_admin?................................"     
        individual_contacts = cuser.organization.individual_contacts.order("#{sort_column} #{sort_direction}")
      else
        puts "coming to not admin................................"     
        individual_contacts = cuser.organization.individual_contacts.where("owner_id=? OR is_public=?", cuser.id, true).order("#{sort_column} #{sort_direction}")
      end
    else
      puts "coming to no tab present................................"     
      individual_contacts = cuser.organization.individual_contacts.where("owner_id=? ", cuser.id).order("#{sort_column} #{sort_direction}")
     
    end
    if params[:sSearch].present?
      individual_contacts = individual_contacts.where("first_name like :search or email like :search", search: "%#{params[:sSearch]}%")
    end
    all_contacts = individual_contacts.where("is_archive=?",false).includes(:deals_contacts,:tasks)
    all_contacts.paginate(:page => page, :per_page => per_page)
  end
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 20
  end

  def sort_column
    columns = %w[id first_name email]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_company_column
    columns = %w[id name email]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "asc" ? "desc" : "asc"
  end
end

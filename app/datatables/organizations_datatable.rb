  class OrganizationsDatatable
  include ApplicationHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: organizations_info.count,
      iTotalDisplayRecords: organizations.total_entries,
      aaData: data
    }
  end

private

  def organizations_info
    Organization.organization_list
  end
  def get_last_activity(last_activity_dt)
    if last_activity_dt.present?
      dt = last_activity_dt
      today = Time.zone.now.strftime('%Y-%m-%d')
      yesterday = (Time.zone.now - (24 * 60 * 60)).strftime('%Y-%m-%d')
      day_before_yesterday = (Time.zone.now - (48 * 60 * 60)).strftime('%Y-%m-%d')
      if (Date.today.to_s == DateTime.parse(dt.to_s).strftime('%Y-%m-%d').to_s)
        "Today #{DateTime.parse(dt.to_s).strftime('%H:%M %p').to_s}"
      else
        if (yesterday.to_s == DateTime.parse(dt.to_s).strftime('%Y-%m-%d').to_s)
          "Yesterday #{DateTime.parse(dt.to_s).strftime('%H:%M %p').to_s}"
        else
          if (yesterday.to_s == DateTime.parse(dt.to_s).strftime('%Y-%m-%d').to_s)
            "Yesterday #{DateTime.parse(dt.to_s).strftime('%H:%M %p').to_s}"
          else
            dt.strftime("%b %d, %Y %H:%M %p")
          end
        end
      end
    end
  end

  def data
    organizations.map do |organization|
      google_users = organization.users.select {|r| r.provider.include?("google") if r.provider.present? }.count
      linkedin_users = organization.users.select {|r| r.provider.include?("linkedin") if r.provider.present? }.count
      regular_users = organization.users.select {|r| r.provider.nil? }.count
      if (super_admin = organization.users.where("admin_type=?",1).first).present?
        result = Geocoder.search(super_admin.last_sign_in_ip)
        geo_data  = result.first.data if result.present? && result.first.present?
        location = geo_data["country_name"] if geo_data.present?
      end
      [
        h(organization.id), #row[0]
        h(organization.name), #row[1]
        h(organization.email.present? ? organization.email : (organization.users.present? ? organization.users.first.email : "N/A") ), #row[2]
        h(organization.created_at.strftime("%b %d, %Y")), #row[3]
        h(organization.users.first.present? ? organization.users.first.time_zone.present? ? organization.users.first.time_zone : "N/A" : "N/A"), #row[4]
        h("Google (" + google_users.to_s + "), Linkedin (" + linkedin_users.to_s + "), Regular (" + regular_users.to_s + ")"), #row[5]
        h(organization.activities.present? ? get_last_activity(organization.activities.last.created_at.in_time_zone("Kolkata")) : "N/A"), #row[6]
        h(organization.users.present? ? organization.users.count - 1  : 0),  #row[7]
        h(organization.deals.count), #row[8]
        h(organization.individual_contacts.count), #row[9]
        h(organization.tasks.count), #row[10]
        h(!organization.present?), #row[11]
        h(organization.change_permissions), #row[12]
        h(organization.get_plan), #row[13]
        h(location.present? ? location : "N/A"), #row[14]
        h(organization.users.present? && organization.users.where("admin_type=?", 1).present? ? ( organization.users.where("admin_type=?", 1).first.is_email_bounce ? "true" : "false" ) : "false" ), #row[15]
        h(organization.activities.present? ? organization.activities.count : "0"), #row[16]
        h(organization.user_subscriptions.present? && organization.user_subscriptions.active.present? && !organization.user_subscriptions.active.last.cancel_date.present?), #row[17]
        h(organization.user_subscriptions.present? && organization.user_subscriptions.active.present? && organization.user_subscriptions.active.last.cancel_date.present?), #row[18]
        h(organization.user_subscriptions.present? && organization.user_subscriptions.active.present? ? organization.user_subscriptions.active.last.price : "") #row[19]
      ]
    end
  end
  
  def organizations
    @sources ||= fetch_organizations
  end

  def fetch_organizations
    organizations = organizations_info
    if params[:filter_by].present? && params[:filter_by] != "All"
      get_date_range
      if params[:filter_by_plan].present? && params[:filter_by_plan] != "All"
        if params[:filter_by_plan] == "Pro plan"
          organizations =  organizations.includes(:user_subscriptions).where("organizations.id IN (?) AND (user_subscriptions.subscription_start_date >= ? AND user_subscriptions.subscription_start_date <= ?)", UserSubscription.all.map(&:organization_id), @start_date, @end_date)
        elsif params[:filter_by_plan] == "Trial"
          organizations = organizations.where("is_trial_expired=? AND (created_at >= ? AND created_at <= ?)",false, @start_date, @end_date)
        elsif params[:filter_by_plan] == "Trial Expired"
          organizations = organizations.where("is_trial_expired=? AND is_free_plan=? AND id NOT IN (?) AND (trial_expires_on >= ? AND trial_expires_on <= ?)", true, false, UserSubscription.all.map(&:organization_id), @start_date, @end_date)
        elsif params[:filter_by_plan] == "Free"
          organizations = organizations.where("is_free_plan=? AND (created_at >= ? AND created_at <= ?)",true, @start_date, @end_date)
        end
      else
        organizations = organizations.where("(created_at >= ? AND created_at <= ?)", @start_date, @end_date)
      end
    else
      if params[:filter_by_plan].present? && params[:filter_by_plan] != "All"
        if params[:filter_by_plan] == "Pro plan"
          organizations =  organizations.includes(:user_subscriptions).where("organizations.id IN (?)", UserSubscription.all.map(&:organization_id))
        elsif params[:filter_by_plan] == "Trial"
          organizations = organizations.where("is_trial_expired=?",false)
        elsif params[:filter_by_plan] == "Trial Expired"
          organizations = organizations.where("is_trial_expired=? AND is_free_plan=? AND id NOT IN (?)", true, false, UserSubscription.all.map(&:organization_id))
        elsif params[:filter_by_plan] == "Free"
          organizations = organizations.where("is_free_plan=?",true)
        end
      else
        organizations
      end
    end
    
    if(sort_column != "")
      # if sort_column == "activities"
      #   puts "----------------------------------"
      #   order_by = "activities.created_at #{sort_direction}"
      #   p order_by
      # else
      #   order_by = "#{sort_column} #{sort_direction}"
      # end
      organizations = organizations.reorder(nil).order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
      #organizations = organizations.page(page).per_page(per_page)
    else
      organizations = organizations.order("created_at desc").page(page).per_page(per_page)
    end
    if params[:sSearch].present?
      organizations = organizations.where("(name like :search)", search: "%#{params[:sSearch]}%")
    end
    organizations
  end
  def get_date_range
    if(params[:filter_by] == "This Quarter" || params[:filter_by] == "Last Quarter" ) 
      @curr_quarter =  get_month_quarter Date.today
      if params[:filter_by] == "This Quarter"
        @current_quarter = @curr_quarter
      else
        @current_quarter = @curr_quarter - 1
      end
      if(@current_quarter == 1)
        @start_date = DateTime.new(Time.zone.now.year,1,1)
        @end_date = DateTime.new(Time.zone.now.year,3,31)
      elsif(@current_quarter == 2)
        @start_date = DateTime.new(Time.zone.now.year,4,1)
        @end_date = DateTime.new(Time.zone.now.year,6,30)
      elsif(@current_quarter == 3)
        @start_date = DateTime.new(Time.zone.now.year,7,1)
        @end_date = DateTime.new(Time.zone.now.year,9,30)
      elsif(@current_quarter == 4)
        @start_date = DateTime.new(Time.zone.now.year,10,1)
        @end_date = DateTime.new(Time.zone.now.year,12,31)
      elsif(@current_quarter == 0)
        @start_date = DateTime.new(Time.zone.now.year - 1,10,1)
        @end_date = DateTime.new(Time.zone.now.year - 1,12,31)
      end
    elsif params[:filter_by] == "This Week"
      @start_date = 0.week.ago.beginning_of_week
      @end_date = 0.week.ago.end_of_week
      
    elsif params[:filter_by] == "Last Week"
      @start_date = 1.week.ago.beginning_of_week
      @end_date = 1.week.ago.end_of_week
    
    elsif params[:filter_by] == "This Month"
      @start_date = 0.month.ago.beginning_of_month
      @end_date = 0.month.ago.end_of_month
    elsif params[:filter_by] == "Last Month"
      @start_date = 1.month.ago.beginning_of_month
      @end_date = 1.month.ago.end_of_month

    elsif params[:filter_by] == "This Year"
        @start_date = 0.year.ago.beginning_of_year
        @end_date = 0.year.ago.end_of_year   
    elsif params[:filter_by] == "Last Year"
        @start_date = 1.year.ago.beginning_of_year
        @end_date = 1.year.ago.end_of_year
    end
  end
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[organizations.id organizations.name organizations.id organizations.created_at organizations.id organizations.id organizations.id activities.created_at id]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "asc" ? "desc" : "asc"
  end
end

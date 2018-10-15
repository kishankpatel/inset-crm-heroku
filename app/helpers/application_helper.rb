module ApplicationHelper
include TasksHelper
include DeviseHelper
require 'net/http'
require 'uri'

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end
  def all_countries
    @get_all_countries = Array.new
    
    deals = Deal.where(organization_id: @current_user.organization_id).uniq_by(&:country_id)
    existing_countries = []
    deals.each do |deal|
      if !deal.country_id.nil?
        country = Country.find_by_id(deal.country_id)
        existing_countries << {"name" => country.name, "id" => country.id}
      end
    end
    total_countries = Country.select("id, name").to_a
    remaining_country = total_countries - existing_countries

    existing_countries.each do |exc|
      @get_all_countries << exc
    end
    @get_all_countries << {"id" => "", "name" => "----------------"}
    remaining_country.each do |rmc|
      @get_all_countries << rmc
    end
    return @get_all_countries

  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  
def qualified_deals_count
  
   count_condition=get_deal_status_count([1,2,3,4,5,6])
   @qualified_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?)", [2]).count
    return @qualified_deals
end
  def new_deals_count(status=[1])
    if(@current_user.is_super_admin? || @current_user.is_admin?)
     deals = @current_user.organization.deals.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)    
    else
     deals = @current_user.all_assigned_deal.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)
    end
    deals.count
  end
  
  def new_deals_three_month(status=[1])
    if(@current_user.is_super_admin? || @current_user.is_admin?)
     deals = @current_user.organization.deals.last_three_months.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status).count
    else
     deals = @current_user.all_assigned_deal.last_three_months.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status).count
    end
    deals
  end
  
  
  
  
  def total_notification_count
      ##TODO uncomment to add attention deal count..
     new_deals_count.to_i + badge_today.to_i + badge_overdue.to_i + qualified_deals_count.to_i #+ attention_deals_count.to_i

  end
  
  def get_deal_status_count(status, user=nil, associated_by=nil)
    #deals=@current_user.organization.deals.includes(:deal_status).where("deal_statuses.original_id IN (?) ", status)
    query_condition=[]
    if user.present? && associated_by.present? && status.length == 1 && (status.include?1) 
     if associated_by == "created by"
#      deals = user.my_created_deals
      query_condition.where("initiated_by= ? and deals.organization_id = ?",user.id,user.organization_id)
     elsif associated_by == "assigned to"
#      deals = user.all_assigned_deal
      query_condition.where("assigned_to = ? and deals.organization_id = ? ",user.id, user.organization_id)
     end
    else
      if(@current_user.is_super_admin? || @current_user.is_admin?)
#        deals = @current_user.organization.deals
        #query_condition.where("is_active=? AND deals.organization_id = ? ", true, @current_user.organization.id)
        query_condition.where("deals.organization_id = ? ", @current_user.organization.id)
      elsif !@current_user.is_super_admin? && !@current_user.is_admin?
        if status.length == 1 && (status.include?1)
#          deals = @current_user.all_deals_dashboard
          query_condition.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",@current_user.id,@current_user.id,@current_user.organization_id)
        elsif status.uniq.sort == [1,2,3,4,5,6].uniq.sort
#          deals = @current_user.all_assigned_deal
          query_condition.where("assigned_to = ? and deals.organization_id = ? ",@current_user.id, @current_user.organization_id)
        else
#          deals = @current_user.my_deals
          query_condition.where("(assigned_to = ? or initiated_by= ?) and deals.organization_id = ?",@current_user.id,@current_user.id,@current_user.organization.id)
        end
      end
   end
#    deals.includes(:deal_status).where("deal_statuses.original_id IN (?) and is_active=? ", status, true)
    
    query_condition
  end
  
  def quarter_month_numbers(date)    
    #quarters = [[1,2,3], [4,5,6], [7,8,9], [10,11,12]]
    quarters = [[1], [2], [3], [4]]
    quarters[(date.month - 1) / 3]    
    
  end

  def get_month_quarter(date)
    quarter = ((date.month - 1) / 3) + 1
  end

  def format_activity_date(date)
    if date == Date.today.strftime("%b %d, %Y")
      "Today"
    elsif date == Date.yesterday.strftime("%b %d, %Y")
      "Yesterday"
    elsif (date > Date.today.strftime("%b %d, %Y") - 7) && (date < Date.yesterday.strftime("%b %d, %Y"))
      "Weekday"
    else
       date.strftime("%b %d, %Y")
    end
  end
  
  def get_priority_color(obj)
    clr="green"
    if obj.priority_id == 1
      clr="red"
    elsif obj.priority_id == 2
      clr="blue"
    end
    clr
  end
  
  def get_deal_status_count_within_four_weeks()
    #deals=@current_user.organization.deals.includes(:deal_status).where("deal_statuses.original_id IN (?) ", status)
    condition_four_weeks=[]
   if(@current_user.is_super_admin? || @current_user.is_admin?)    
#     deals = @current_user.organization.deals.includes(:deal_status).within_four_weeks.where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)    
     condition_four_weeks.where("deals.created_at >=? AND is_active=? AND (deals.is_public = true and deals.organization_id = ?)", 4.weeks.ago, true, @current_organization.id)
    else
##      deals = @current_user.all_deals.includes(:deal_status).within_four_weeks.where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)
      condition_four_weeks.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",@current_user.id,@current_user.id,@current_organization.id)
#     #deals=deals.where("(deals.assigned_to=? )", @current_user.id) unless @current_user.is_admin?
    end
    
    condition_four_weeks
  end
  
  def get_deal_status_count_statistics(status)
    deals = @current_user.all_assigned_or_created_deals.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", status)
    deals
  end
  
  ##for leader dashboard  
  def get_deal_status_won_count(user,status,start_date,end_date)
    
    deals = user.all_assigned_deal.by_range(start_date,end_date).includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", last_deal_status.original_id)
   
    deals
  end
  def last_deal_status
    deal_status = @current_organization.deal_statuses.order("original_id desc").first
    deal_status
  end


  ##allow to login if siteadmin approves the organization and its users
  def approve_all_users_organization org_email
    org = Organization.find_by_email org_email
    if org.present?
       org.users.update_all(:is_active => true)
    end
  end
  
  ##Disallow to login if siteadmin approves the organization and its users
  def  disapprove_all_users_organization org_email
    org = Organization.find_by_email org_email
    if org.present?
       org.users.update_all(:is_active => false)       
    end
  end
  
  ##Used for profile page
  def get_deal_status_count_user(status, user)

   #deals=@current_user.organization.deals.includes(:deal_status).where("deal_statuses.original_id IN (?) ", status)
    query_condition=[]
      if(user.is_super_admin? || user.is_admin?)
        #query_condition.where("is_active=? AND deals.organization_id = ? ", true, user.organization_id)
        query_condition.where("deals.organization_id = ? ", user.organization_id)
      elsif !user.is_super_admin? && !user.is_admin?
        if status.length == 1 && (status.include?1)
          query_condition.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",user.id,user.id,user.organization_id)
        elsif status.uniq.sort == [1,2,3,4,5,6].uniq.sort
          query_condition.where("assigned_to = ? and deals.organization_id = ? ",user.id, user.organization_id)
        else
          query_condition.where("(assigned_to = ? or initiated_by= ?) and deals.organization_id = ?",user.id,user.id,user.organization.id)
        end
     end
    query_condition
  end
  
  ##for report section total deals won for admin  
  def get_deal_status_total_won(status,start_date,end_date)
    deals = @current_user.organization.deals.by_range(start_date,end_date).includes(:deal_status).where("deal_statuses.original_id IN (?) ", status).includes(:deal_moves).order("deal_moves.created_at desc")
   
    deals
  end
  
  def all_org_users
   if @current_user.organization.present?
		@current_user.organization.users.where("invitation_token IS ? and is_active = ? and is_blocked = ?", nil,true,false).order("first_name").each do |u|
		  if u.id == @current_user.id
			u.first_name="me"
			u.last_name = ""
		  end
		end
	end
  end


  def all_users_of_org
   if @current_user.organization.present?
    @current_user.organization.users.where("invitation_token IS ? and is_active = ? and first_name IS NOT NULL", nil,true).order("first_name").each do |u|
      if u.id == @current_user.id
      u.first_name="me"
      u.last_name = ""
      end
    end
   end
  end
  
  def select_all_org_users
    @current_user.organization.users.where("invitation_token IS ? and is_active = ? and is_blocked = ?", nil, true, false).order("is_active desc,first_name").each do |u|
      if u.id == @current_user.id
        u.first_name="me"
        u.last_name = ""
      end
    end
  end

  def all_org_users_with_blocked
   if @current_user.organization.present?
    @current_user.organization.users.where("invitation_token IS ? and is_active = ?", nil,true).order("first_name").each do |u|
      if u.id == @current_user.id
      u.first_name="me"
      u.last_name = ""
      end
    end
  end
  end

  def get_deal_index_status_count(status, user, associated_by)
    query_condition=[]
    if user.present?
       if associated_by == "created by"
        query_condition.where("deal_statuses.is_active = ? and initiated_by= ? and deals.organization_id = ?",true,user.id,user.organization_id)
       elsif associated_by == "assigned to"
        query_condition.where("deal_statuses.is_active = ? and assigned_to = ? and deals.organization_id = ? ",true,user.id, user.organization_id)
       end
    end
    query_condition
  end
  
  
  def attention_deals_count
    adc=AttentionDeal.select("deal_count").where("user_id=? AND organization_id=?", @current_user.id, @current_organization.id).first
    adc.present? ? adc.deal_count : 0
  end
  
  def date_format(date)
       dt = date.strftime("%Y").to_s == Time.zone.now.year.to_s ? date.strftime("%b %d") : date.strftime("%b %d, %Y")
       dt
  end  
  
  def assigned_to_users
     @c = []
     user = @current_user.organization.users.where("invitation_token IS ? and is_active = ?", nil,true)
     user.each do |a|
        @c << a.email
     end
     return @c
  end  
  
  def current_env
        Rails.env
  end
  
  
  def deal_status_count_last_one_month(in_days= nil)
    #deals=@current_user.organization.deals.includes(:deal_status).where("deal_statuses.original_id IN (?) ", status)
    condition_four_weeks=[]
   if(@current_user.is_super_admin? || @current_user.is_admin?)    
     if in_days.present?
      if(in_days == "30-Days")
        time = Time.zone.now - 1.month
      elsif(in_days == "60-Days")
        time = Time.zone.now - 2.months
      elsif(in_days == "90-Days")
        time = Time.zone.now - 3.months
      end
     else
      time = Time.zone.now - 1.month
     end
     condition_four_weeks.where('deals.created_at BETWEEN ? and ?',time,Time.zone.now).where("deals.is_active=? AND (deals.is_public = true and deals.organization_id = ?)", true, @current_organization.id)
    else
      condition_four_weeks.where("assigned_to = ? or initiated_by= ? or (deals.is_public = true and deals.organization_id = ?)",@current_user.id,@current_user.id,@current_organization.id)
    end
    condition_four_weeks
  end
  

  def check_deal_is_opportunity(deal_id)
    return Proc.new {
      deal = Deal.find deal_id
      unless deal.is_opportunity
        puts "-------deal #{deal.id}"
        if deal.organization.present?
          won_id = deal.organization.won_deal_status().id
          if won_id.present?
            deal.deals_contacts.map { |contact| 
              if  contact.contactable.present? 
                contact.contactable.deals_contacts.each do |dc|
                  if dc.deal.present?
                    if dc.deal.deal_status_id == won_id
                       puts "-----------> found won deals  #{dc.deal.id}"
                       deal.update_column :is_opportunity, true 
                       break
                    end
                  end
                end
              end
             }
           end
         end
       end
     }
  end
  
  def get_image_url path,source=nil   
     # https://www.linkedin.com/company/texas-creative?trk=tyah&trkInfo=tarId%3A1405914736988%2Ctas%3ATexas+Creative%2Cidx%3A1-1-1
      page = Nokogiri::HTML(open(path))
	    #page_html = page.to_html
	    #doc = Nokogiri::HTML::DocumentFragment.parse(page_html)
	    #url = ""
      #@image = doc.search('img')
      begin 
        unless path.include?("/company/")
          img = page.css("img[class='photo']")
        else
          img = page.css("img[class='hero-img']")
        end
        return img[0]["src"]
       rescue
          return  "not_found"
       end
    end
  
  def format_date(date)
    elapsed = Time.now - date
    case elapsed
      when 0..60 then "#{elapsed.to_i} sec#{'s' if elapsed.to_i > 1} ago"
      when 0..60*60 then "#{(elapsed / 60).to_i} min#{'s' if (elapsed / 60).to_i > 1} ago"
      when 60*60..60*60*24 then "#{(elapsed / (60 * 60)).to_i} hour#{'s' if (elapsed / (60*60)).to_i > 1} ago"
      when 60*60*24..60*60*24*2 then "1 day #{(elapsed.to_i - (60*60*24))/(60*60)} hour#{'s' if ((elapsed - 60*60*24)/(60*60)).to_i > 1} ago"
      when 60*60*24..60*60*24*2 then "1 day"
      when 60*60*24*2..60*60*24*7 then "#{(elapsed/(60*60*24)).to_i} days ago"
      when 0..60*60*24*7 then "#{time_ago_in_words(date)} ago"
    else date.strftime("%b %d, %Y @ %H:%M ")
    end
  end
  def send_weekly_digest_mail(deals,assigned_to,set_time_zone,frequency)
    total_assigned_deal = deals.count
   if deals.first.assigned_user.present?
        user = deals.first.assigned_user
        assigned_email = user.email
        full_name = user.full_name
    else
          user = User.where("id=?",assigned_to).first
          if user.present?
                assigned_email = user.email
                full_name =  user.full_name
          end
     end
     assgneddeals = deals.take(10)
     puts "------------>mail sending #{assigned_to} "
     if is_valid_user_email assigned_email  
       Notification.weekly_digest_notification(assigned_email,full_name,assgneddeals,set_time_zone,user.id,total_assigned_deal, assgneddeals.length,frequency).deliver
     end
     user.update_column :digest_mail_date, set_time_zone
	 @file = File.new("#{Rails.root}/log/digest_mail.log", "a")
	 @file.puts 'Notification for Digest Mail' + ' ' + "executed on" + ' ' + Time.now.to_s
     @file.puts "User ID---->" + ' :' + user.id.to_s + " Email:" + user.email
	 @file.puts "User enable digest mail: " + user.user_preference.weekly_digest.to_s
	 @file.puts "User set frequency: " + user.user_preference.digest_mail_frequency
	 @file.puts "User time now: " + set_time_zone.to_s
     @file.puts "User time zone: " + user.time_zone
     @file.close

  end

  def get_contacts_having_opportunity
    ic_id= @current_organization.deals_contacts.where("contactable_type=? AND deal_id is not null AND contactable_id is not null", "IndividualContact").pluck("contactable_id").uniq
    return @current_organization.individual_contacts.where("id in(?) AND is_archive=?", ic_id,false).order("first_name asc, last_name asc")
  end

  def is_valid_user_email email=nil
    if email.present?
      user = User.where("email = ?", email).first
      if user.present?
          user.is_active && !user.is_disabled && !user.is_blocked
      end
    else
      @current_user.present?
    end
  end

  def lead_total_amount(lead)
    # lead.deals_contacts.map{|dc| dc.deal if dc.deal.present? && dc.deal.is_active && dc.deal.amount.present?}.compact.sum
    org_amount_type = get_org_amount_type(lead.organization)
    deals = lead.deals_contacts.map{|dc| dc.deal if dc.deal.present? && dc.deal.is_active && dc.deal.amount.present? && (!dc.deal.is_won.to_s.present? || dc.deal.is_won.to_s=="true")}.compact
    sum_amount = 0   
    deals.each do |deal|
      currency_type = deal.currency_type
      currency = get_deal_amount_type(deal)
      if eval(currency) == :dzd || eval(org_amount_type) == :dzd
        begin
          from=eval(currency).upcase.to_s.chomp(':')
          to=eval(org_amount_type).upcase.to_s.chomp(':')
          dzd_conversion = URI('https://free.currencyconverterapi.com/api/v5/convert?q='+from+'_'+to+'&compact=y').read
          sum_amount = sum_amount + deal.amount*dzd_conversion.match(/[.\d]+/)[0].to_f
        rescue
          "0.00"
        end
      else
        begin
          sum_amount = sum_amount + deal.amount.in(eval(currency)).to(eval(org_amount_type)).to_f
        rescue
          "0.00"
        end      
      end
    end
    sum_amount.round(2)
  end

  def lead_stage_total_amount(stage, user_id=nil)
    puts "inside lead_stage_total_amount >>>>>>>>>>>>>>>>>>>>>>"
    org_amount_type = get_org_amount_type(stage.organization)
    if user_id.present? && user_id != "All"
      deals = @current_organization.deals.joins(:deals_contacts).where("is_won IS NULL and amount IS NOT NULL and deals.is_active = true and deals.deal_status_id = #{stage.id} and ((deals.assigned_to = #{user_id} or deals.initiated_by = #{user_id} ) or (deals_contacts.contactable_type = 'IndividualContact' and deals_contacts.contactable_id in (select id from individual_contacts where owner_id = #{user_id})))")
    else
      deals = @current_organization.deals.by_is_active.where("deal_status_id=? and amount IS NOT NULL and is_won IS NULL", stage.id)
    end
    sum_amount = 0.0
    deals.each do |deal|
      puts deal.amount
      currency_type = deal.currency_type
      currency = get_deal_amount_type(deal)
      if eval(currency) == :dzd || eval(org_amount_type) == :dzd
        puts "coming to dzd ......................"
        begin
          from=eval(currency).upcase.to_s.chomp(':')
          to=eval(org_amount_type).upcase.to_s.chomp(':')
          dzd_conversion = URI('https://free.currencyconverterapi.com/api/v5/convert?q='+from+'_'+to+'&compact=y').read
          sum_amount = sum_amount + deal.amount*dzd_conversion.match(/[.\d]+/)[0].to_f
        rescue => ex
          puts ex.message
          "0.00"
        end
      else
        puts "coming to else part of dzd ......................"
        begin
          puts deal.amount.in(eval(currency))
          puts org_amount_type
           
          puts deal.amount.in(eval(currency)).to(eval(org_amount_type))
          sum_amount = sum_amount + deal.amount.in(eval(currency)).to(eval(org_amount_type)).to_f
        rescue => ex
          puts "failure in exchange gem ............"
          puts ex.message
          begin
            sum_amount = sum_amount + Money.new(deal.amount * 100, eval(currency)).exchange_to(eval(org_amount_type)).to_f
            puts sum_amount
          rescue => ex
            puts "failure in money gem ............"
            puts ex.message
            "0.00"
          end
          
        end
        
      end
    end
    
    sum_amount.round(2)
  end
  def opportunity_amount(deal)
    org_amount_type = get_org_amount_type(deal.organization)
    currency_type = deal.currency_type
    if deal.amount.present?
      currency = get_deal_amount_type(deal)
      if eval(currency) == :dzd || eval(org_amount_type) == :dzd
        begin
          from=eval(currency).upcase.to_s.chomp(':')
          to=eval(org_amount_type).upcase.to_s.chomp(':')
          dzd_conversion = URI('https://free.currencyconverterapi.com/api/v5/convert?q='+from+'_'+to+'&compact=y').read
          deal.amount*dzd_conversion.match(/[.\d]+/)[0].to_f
        rescue
          "0.00"
        end
      else
        begin
          deal.amount.in(eval(currency)).to(eval(org_amount_type)).to_f.round(2)
        rescue
          "0.00"
        end
      end
    else
      "0.00"
    end
  end
  def won_lost_opportunity_amount(opportunities)
    org_amount_type = get_org_amount_type(@current_organization)
    sum_amount = 0
    opportunities.each do |opportunity|
      currency_type = opportunity.currency_type
      currency = get_deal_amount_type(opportunity)
      if eval(currency) == :dzd || eval(org_amount_type) == :dzd
        begin
          from=eval(currency).upcase.to_s.chomp(':')
          to=eval(org_amount_type).upcase.to_s.chomp(':')
          dzd_conversion = URI('https://free.currencyconverterapi.com/api/v5/convert?q='+from+'_'+to+'&compact=y').read
          sum_amount = sum_amount + opportunity.amount*dzd_conversion.match(/[.\d]+/)[0].to_f
        rescue
          "0.00"
        end
      else
        begin
          sum_amount = sum_amount + opportunity.amount.in(eval(currency)).to(eval(org_amount_type)).to_f
        rescue
          "0.00"
        end
      end
    end
    sum_amount.round(2)
  end
  def report_total_amount_except_lost(deals)
    org_amount_type = get_org_amount_type(@current_organization)
    sum_amount = 0
    deals.each do |deal|
      currency_type = deal.currency_type
      currency = get_deal_amount_type(deal)
      if eval(currency) == :dzd || eval(org_amount_type) == :dzd
        begin
          from=eval(currency).upcase.to_s.chomp(':')
          to=eval(org_amount_type).upcase.to_s.chomp(':')
          dzd_conversion = URI('https://free.currencyconverterapi.com/api/v5/convert?q='+from+'_'+to+'&compact=y').read
          sum_amount = sum_amount + deal.amount*dzd_conversion.match(/[.\d]+/)[0].to_f
        rescue
          "0.00"
        end
      else
        begin
          sum_amount = sum_amount + deal.amount.in(eval(currency)).to(eval(org_amount_type)).to_f
        rescue
          "0.00"
        end
      end
    end
    sum_amount.round(2)
  end
  def opportunities_amount(deals, org)
    org_amount_type = get_org_amount_type(org)
    sum_amount = 0
    deals.each do |deal|
      if deal.present?  
        currency_type = deal.currency_type
        currency = get_deal_amount_type(deal)
        if eval(currency) == :dzd || eval(org_amount_type) == :dzd
          begin
            from=eval(currency).upcase.to_s.chomp(':')
            to=eval(org_amount_type).upcase.to_s.chomp(':')
            dzd_conversion = URI('https://free.currencyconverterapi.com/api/v5/convert?q='+from+'_'+to+'&compact=y').read
            sum_amount = sum_amount + deal.amount*dzd_conversion.match(/[.\d]+/)[0].to_f
          rescue
            "0.00"
          end
        else
          begin
            sum_amount = sum_amount + deal.amount.in(eval(currency)).to(eval(org_amount_type)).to_f
          rescue
            "0.00"
          end
        end
      end
    end
    sum_amount.round(2)
  end

  def invoices_total condition
    if condition == "paid"
      invoices = @current_organization.invoices.where(status: "Paid")
    elsif condition == "is_sent"
      invoices = @current_organization.invoices.where(is_sent: true)
    else
      invoices = @current_organization.invoices
    end
    org_amount_type = get_org_amount_type(@current_organization)
    sum_amount = 0
    invoices.each do |invoice|
      currency = get_invoice_amount_type(invoice)
      if eval(currency) == :dzd || eval(org_amount_type) == :dzd
        begin
          from = eval(currency).upcase.to_s.chomp(':')
          to = eval(org_amount_type).upcase.to_s.chomp(':')
          dzd_conversion = URI('https://free.currencyconverterapi.com/api/v5/convert?q='+from+'_'+to+'&compact=y').read
          sum_amount = sum_amount + (invoice.total_amount.to_f)*dzd_conversion.match(/[.\d]+/)[0].to_f
        rescue
          "0.00"
        end
      else
        begin
          if invoice.total_amount.to_f > 0
            if eval(currency) != eval(org_amount_type)
              sum_amount = sum_amount + (invoice.total_amount.to_f).in(eval(currency)).to(eval(org_amount_type)).to_f
            else
              sum_amount = sum_amount + (invoice.total_amount.to_f)
            end
          else
            sum_amount = sum_amount + 0
          end
        rescue
          sum_amount = sum_amount + 0
        end
      end
    end
    sum_amount.round(2)
  end

  def get_invoice_amount_type(invoice)
    if invoice.currency == 'SGD'
      currency = ':sgd'
    elsif invoice.currency == 'EUR'
      currency = ':eur'
    elsif invoice.currency == 'INR'
      currency = ':inr'
    elsif invoice.currency == 'GBP'
      currency = ':gbp'
    elsif invoice.currency == 'DZD'
      currency = ':dzd'
    else
      currency = ':usd'
    end
    currency
  end

  def get_deal_amount_type(deal)
    if deal.currency_type == 'S$'
      currency = ':sgd'
    elsif deal.currency_type == '€'
      currency = ':eur'
    elsif deal.currency_type == 'INR'
      currency = ':inr'
    elsif deal.currency_type == '£'
      currency = ':gbp'
    elsif deal.currency_type == 'DZD'
      currency = ':dzd'
    elsif deal.currency_type == 'SGD'
      currency = ':sgd'
    else
      currency = ':usd'
    end
    currency
  end

  def get_org_amount_type(org)
    if org.default_currency == 'S$'
      currency = ':sgd'
    elsif org.default_currency == '€'
      currency = ':eur'
    elsif org.default_currency == 'INR'
      currency = ':inr'
    elsif org.default_currency == '£'
      currency = ':gbp'
    elsif org.default_currency == 'DZD'
      currency = ':dzd'
    elsif org.default_currency == 'SGD'
      currency = ':sgd'
    else
      currency = ':usd'
    end
    currency
  end

  def get_org_currency_symbol(org)
    if org.default_currency == 'S$'
      currency = '$'
    elsif org.default_currency == '€'
      currency = '€'
    elsif org.default_currency == 'INR'
      currency = 'INR'
    elsif org.default_currency == '£'
      currency = '£'
    elsif org.default_currency == 'DZD'
      currency = 'DZD'
    else
      currency = '$'
    end
    currency
  end
  #Get user gravtar url by user email
  def gravatar_url(email)
    begin
      gravatar_check = "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}.png?d=404"
      uri = URI.parse(gravatar_check)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      if response.code.to_i != 404 # from d=404 parameter
        return gravatar_check
      else
        return nil
      end
    rescue
      return nil
    end
  end
  def get_durations(duration)
    p duration
    case (duration)
      when 'current_week'
        @start_date = Date.today.at_beginning_of_week - 1.day 
        @end_date = Date.today.end_of_week - 1.day
      when 'last_week'
        @start_date = Date.today.at_beginning_of_week - 7.days
        @end_date = Date.today.at_beginning_of_week - 1.day
      when 'current_month'
        @start_date = Date.today.at_beginning_of_month
        @end_date = Date.today.end_of_month
      when 'last_month'
        @start_date = (Date.today - 1.month).at_beginning_of_month
        @end_date = Date.today.at_beginning_of_month - 1.day
      when 'current_year'
        @start_date = Date.today.at_beginning_of_year
        @end_date = Date.today
      when 'last_year'
        @start_date = (Date.today - 1.year).at_beginning_of_year
        @end_date = Date.today.at_beginning_of_year - 1.day
      when 'current_next_thirty'
          @start_date =  Date.today
          @end_date = (Date.today + 30.days)
      when 'custom_next_week'
          @start_date =  ((params[:end_date].to_date+2.day).at_beginning_of_week - 1.day )
          @end_date = ((params[:end_date].to_date+2.day).end_of_week - 1.day )
      when 'custom_next_month'
        @start_date =  params[:end_date].to_date.end_of_month + 1.days
        @end_date =  (params[:end_date].to_date.end_of_month + 1.days).end_of_month
      when 'custom_next_thirty'
        @start_date = (params[:end_date].to_date + 1.days)
        @end_date = (params[:end_date].to_date + 31.days)
      when 'custom_prev_week'
        puts "inside custom_prev_week................."
        p params[:start_date]
        @start_date =  params[:start_date].to_date.at_beginning_of_week - 1.day
        @end_date = params[:start_date].to_date.at_beginning_of_week + 5.day
        p @start_date
        p @end_date
      when 'custom_prev_month'
        @start_date = (params[:start_date].to_date - 1.month).at_beginning_of_month
        @end_date = params[:start_date].to_date.at_beginning_of_month - 1.day
      when 'custom_prev_thirty'
        @start_date = (params[:start_date].to_date - 31.days)
        @end_date = (params[:start_date].to_date- 1.days)
      when 'custom'
        @start_date = Date.strptime(params[:start_date], '%m/%d/%Y')
        @end_date = Date.strptime(params[:end_date], '%m/%d/%Y')
        
      else
        nil
    end
  end
  def get_color_code_for_minutes_allotted allotted_date, minutes ,max_hours=8,weekends=[5,6]
    
    if(weekends.include? (allotted_date.wday))
      return "#ccc8c8"
    end
    hours = minutes / 60.0
    if(hours > max_hours)
      ##overloaded
      return "#ff0000"  
    elsif (hours > 0 && hours <= max_hours)
      ## Booked
      return "#00ffff"  
    elsif(hours == 0)
      ## Available
      return "#ffffff"  
    end
  end

  def get_file_class extension
    case extension.downcase
      when "jpg","jpeg","png", "bmp", "gif"
        "fa-file-image"
      when "doc","docx"
        "fa-file-doc"
      when "xls","xlsx"
        "fa-file-excel"
      when "pdf"
        "fa-file-pdf"
      else
        "fa-file"
      end
  end
end

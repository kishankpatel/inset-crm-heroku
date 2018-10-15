module HomeHelper

 ##Activites as per organization includes deals,contacts,tasks and notes
 def get_organization_activity_stream org_id
   activities = []
   org = Organization.find org_id
   activities << org.deals
   activities << org.deal_moves
   activities << org.contacts
   activities << org.tasks
   activities << org.attachments
   activities = activities.flatten.sort! { |x,y| y.created_at <=> x.created_at } 
 end

def activity_stream org_id, filter_user=nil, filter_duration=nil, filter_from=nil, filter_to=nil, page =1, per_page=20
    #activities = Organization.find_by_sql("select id,'Organization' as name,created_at from organizations where id = "+org_id.to_s+"
    #UNION ALL
    #select id,'Deal' as name,created_at from deals where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'CompanyContact' as name,created_at from  company_contacts where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'IndividualContact' as name,created_at from individual_contacts where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'DealMove' as name,created_at from deal_moves where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'Task' as name,created_at from tasks where organization_id = "+org_id.to_s+"
    #UNION ALL
    #select id,'Note' as name,created_at from notes where organization_id = "+org_id.to_s+"
    #order by created_at desc limit " + per_page.to_s + " offset " + ((page-1)*per_page).to_s)
    unless params[:pagesource] == "profile"
      if filter_user.present? && filter_user != "All"
        activities = @current_organization.activities.where("activity_user_id=?",filter_user)
      else
        activities = @current_organization.activities
      end
      unless filter_from.present? && filter_to.present?
        if filter_duration.present?
          get_start_and_end_date filter_duration
          activities =  activities.where("created_at >= ? AND created_at <= ?", @start_date, @end_date)
        end
      else
        activities =  activities.where("created_at >= ? AND created_at <= ?", (filter_from.to_date + 1.day).beginning_of_day, filter_to.to_date.end_of_day)
      end
    else
      activities = @current_organization.activities.where("activity_user_id=?",filter_user)
    end
    activities = activities.limit(per_page.to_s).offset(((page-1)*per_page).to_s).order("activity_date desc") 
  end
  
  
  def calculate_ratio_monthwise prev, current, prev_week, current_week
      avg_prev = (prev.to_f / prev_week.to_f)
      avg_cur = (current.to_f / current_week.to_f)
      if avg_prev!= 0
        result = ( avg_cur - avg_prev ) * 100 / avg_prev
      else
        result = ( avg_cur - avg_prev ) * 100 
      end
      result = result.nan? ? 0 : result
  end  
  
  def calculate_ratio_weekwise prev_week, current_week
    if prev_week != 0
      ( current_week.to_f - prev_week.to_f ) * 100 / prev_week.to_f
    else
      ( current_week.to_f - prev_week.to_f ) * 100
    end
  end

  def build_contact_us_info (email, name, comment, need_help, phone=nil,is_remote=false)
      contact = ContactUs.where(:email => email).first
      if contact.nil? || contact.blank?
           a = ContactUs.create :email => email , :is_remote => is_remote
           ContactUsInfo.create :name => name, :comment => comment, :phone => phone, :contact_us => a
      else
          ContactUsInfo.create :name => name, :comment => comment, :phone => phone, :contact_us => contact, :need_help => need_help
      end
  end

  def get_start_and_end_date selected_range
    if(selected_range == "thisquarter" || selected_range == "lastquarter" ) 
      @curr_quarter =  get_month_quarter Date.today
      if selected_range == "thisquarter"
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
    elsif selected_range == "thisweek"
      @start_date = 0.week.ago.beginning_of_week
      @end_date = 0.week.ago.end_of_week      
    elsif selected_range == "lastweek"
      @start_date = 1.week.ago.beginning_of_week
      @end_date = 1.week.ago.end_of_week    
    elsif selected_range == "thismonth"
      @start_date = 0.month.ago.beginning_of_month
      @end_date = 0.month.ago.end_of_month
    elsif selected_range == "lastmonth"
      @start_date = 1.month.ago.beginning_of_month
      @end_date = 1.month.ago.end_of_month
    elsif selected_range == "thisyear"
        @start_date = 0.year.ago.beginning_of_year
        @end_date = 0.year.ago.end_of_year
    elsif selected_range == "lastyear"
        @start_date = 1.year.ago.beginning_of_year
        @end_date = 1.year.ago.end_of_year
    end
  end

  def get_all_time_zones
    time_zones = [
              {value: 'Hawaii', text:'(GMT-10:00) Hawaii'},
              {value: 'Alaska', text:'(GMT-09:00) Alaska'},
              {value: 'Pacific Time (US & Canada)', text:'(GMT-08:00) Pacific Time (US & Canada)'},
              {value: 'Arizona', text:'(GMT-07:00) Arizona'},
              {value: 'Mountain Time (US & Canada)', text:'(GMT-07:00) Mountain Time (US & Canada)'},
              {value: 'Central Time (US & Canada)', text:'(GMT-06:00) Central Time (US & Canada)'},
              {value: 'Eastern Time (US & Canada)', text:'(GMT-05:00) Eastern Time (US & Canada)'},
              {value: 'Indiana (East)', text:'(GMT-05:00) Indiana (East)'},
              {value: '', text:'-------------'},
              {value: 'American Samoa', text:'(GMT-11:00) American Samoa'},
              {value: 'International Date Line West', text:'(GMT-11:00) International Date Line West'},
              {value: 'Midway Island', text:'(GMT-11:00) Midway Island'},
              {value: 'Tijuana', text:'(GMT-08:00) Tijuana'},
              {value: 'Chihuahua', text:'(GMT-07:00) Chihuahua'},
              {value: 'Mazatlan', text:'(GMT-07:00) Mazatlan'},
              {value: 'Central America', text:'(GMT-06:00) Central America'},
              {value: 'Guadalajara', text:'(GMT-06:00) Guadalajara'},
              {value: 'Mexico City', text:'(GMT-06:00) Mexico City'},
              {value: 'Monterrey', text:'(GMT-06:00) Monterrey'},
              {value: 'Saskatchewan', text:'(GMT-06:00) Saskatchewan'},
              {value: 'Bogota', text:'(GMT-05:00) Bogota'},
              {value: 'Lima', text:'(GMT-05:00) Lima'},
              {value: 'Quito', text:'(GMT-05:00) Quito'},
              {value: 'Caracas', text:'(GMT-04:30) Caracas'},
              {value: 'Atlantic Time (Canada)', text:'(GMT-04:00) Atlantic Time (Canada)'},
              {value: 'Georgetown', text:'(GMT-04:00) Georgetown'},
              {value: 'La Paz', text:'(GMT-04:00) La Paz'},
              {value: 'Santiago', text:'(GMT-04:00) Santiago'},
              {value: 'Newfoundland', text:'(GMT-03:30) Newfoundland'},
              {value: 'Brasilia', text:'(GMT-03:00) Brasilia'},
              {value: 'Buenos Aires', text:'(GMT-03:00) Buenos Aires'},
              {value: 'Greenland', text:'(GMT-03:00) Greenland'},
              {value: 'Mid-Atlantic', text:'(GMT-02:00) Mid-Atlantic'},
              {value: 'Azores', text:'(GMT-01:00) Azores'},
              {value: 'Cape Verde Is', text:'(GMT-01:00) Cape Verde Is.'},
              {value: 'Casablanca', text:'(GMT+00:00) Casablanca'},
              {value: 'Dublin', text:'(GMT+00:00) Dublin'},
              {value: 'Edinburgh', text:'(GMT+00:00) Edinburgh'},
              {value: 'Lisbon', text:'(GMT+00:00) Lisbon'},
              {value: 'London', text:'(GMT+00:00) London'},
              {value: 'Monrovia', text:'(GMT+00:00) Monrovia'},
              {value: 'UTC', text:'(GMT+00:00) UTC'},
              {value: 'Amsterdam', text:'(GMT+01:00) Amsterdam'},
              {value: 'Belgrade', text:'(GMT+01:00) Belgrade'},
              {value: 'Berlin', text:'(GMT+01:00) Berlin'},
              {value: 'Bern', text:'(GMT+01:00) Bern'},
              {value: 'Bratislava', text:'(GMT+01:00) Bratislava'},
              {value: 'Brussels', text:'(GMT+01:00) Brussels'},
              {value: 'Budapest', text:'(GMT+01:00) Budapest'},
              {value: 'Copenhagen', text:'(GMT+01:00) Copenhagen'},
              {value: 'Ljubljana', text:'(GMT+01:00) Ljubljana'},
              {value: 'Madrid', text:'(GMT+01:00) Madrid'},
              {value: 'Paris', text:'(GMT+01:00) Paris'},
              {value: 'Prague', text:'(GMT+01:00) Prague'},
              {value: 'Rome', text:'(GMT+01:00) Rome'},
              {value: 'Sarajevo', text:'(GMT+01:00) Sarajevo'},
              {value: 'Skopje', text:'(GMT+01:00) Skopje'},
              {value: 'Stockholm', text:'(GMT+01:00) Stockholm'},
              {value: 'Vienna', text:'(GMT+01:00) Vienna'},
              {value: 'Warsaw', text:'(GMT+01:00) Warsaw'},
              {value: 'West Central Africa', text:'(GMT+01:00) West Central Africa'},
              {value: 'Zagreb', text:'(GMT+01:00) Zagreb'},
              {value: 'Athens', text:'(GMT+02:00) Athens'},
              {value: 'Bucharest', text:'(GMT+02:00) Bucharest'},
              {value: 'Cairo', text:'(GMT+02:00) Cairo'},
              {value: 'Harare', text:'(GMT+02:00) Harare'},
              {value: 'Helsinki', text:'(GMT+02:00) Helsinki'},
              {value: 'Istanbul', text:'(GMT+02:00) Istanbul'},
              {value: 'Jerusalem', text:'(GMT+02:00) Jerusalem'},
              {value: 'Kyiv', text:'(GMT+02:00) Kyiv'},
              {value: 'Pretoria', text:'(GMT+02:00) Pretoria'},
              {value: 'Riga', text:'(GMT+02:00) Riga'},
              {value: 'Sofia', text:'(GMT+02:00) Sofia'},
              {value: 'Tallinn', text:'(GMT+02:00) Tallinn'},
              {value: 'Vilnius', text:'(GMT+02:00) Vilnius'},
              {value: 'Baghdad', text:'(GMT+03:00) Baghdad'},
              {value: 'Kuwait', text:'(GMT+03:00) Kuwait'},
              {value: 'Minsk', text:'(GMT+03:00) Minsk'},
              {value: 'Nairobi', text:'(GMT+03:00) Nairobi'},
              {value: 'Riyadh', text:'(GMT+03:00) Riyadh'},
              {value: 'Tehran', text:'(GMT+03:30) Tehran'},
              {value: 'Abu Dhabi', text:'(GMT+04:00) Abu Dhabi'},
              {value: 'Baku', text:'(GMT+04:00) Baku'},
              {value: 'Moscow', text:'(GMT+04:00) Moscow'},
              {value: 'Muscat', text:'(GMT+04:00) Muscat'},
              {value: 'St. Petersburg', text:'(GMT+04:00) St. Petersburg'},
              {value: 'Tbilisi', text:'(GMT+04:00) Tbilisi'},
              {value: 'Volgograd', text:'(GMT+04:00) Volgograd'},
              {value: 'Yerevan', text:'(GMT+04:00) Yerevan'},
              {value: 'Kabul', text:'(GMT+04:30) Kabul'},
              {value: 'Islamabad', text:'(GMT+05:00) Islamabad'},
              {value: 'Karachi', text:'(GMT+05:00) Karachi'},
              {value: 'Tashkent', text:'(GMT+05:00) Tashkent'},
              {value: 'Chennai', text:'(GMT+05:30) Chennai'},
              {value: 'Kolkata', text:'(GMT+05:30) Kolkata'},
              {value: 'Mumbai', text:'(GMT+05:30) Mumbai'},
              {value: 'New Delhi', text:'(GMT+05:30) New Delhi'},
              {value: 'Sri Jayawardenepura', text:'(GMT+05:30) Sri Jayawardenepura'},
              {value: 'Kathmandu', text:'(GMT+05:45) Kathmandu'},
              {value: 'Almaty', text:'(GMT+06:00) Almaty'},
              {value: 'Astana', text:'(GMT+06:00) Astana'},
              {value: 'Dhaka', text:'(GMT+06:00) Dhaka'},
              {value: 'Ekaterinburg', text:'(GMT+06:00) Ekaterinburg'},
              {value: 'Rangoon', text:'(GMT+06:30) Rangoon'},
              {value: 'Bangkok', text:'(GMT+07:00) Bangkok'},
              {value: 'Hanoi', text:'(GMT+07:00) Hanoi'},
              {value: 'Jakarta', text:'(GMT+07:00) Jakarta'},
              {value: 'Novosibirsk', text:'(GMT+07:00) Novosibirsk'},
              {value: 'Beijing', text:'(GMT+08:00) Beijing'},
              {value: 'Chongqing', text:'(GMT+08:00) Chongqing'},
              {value: 'Hong Kong', text:'(GMT+08:00) Hong Kong'},
              {value: 'Krasnoyarsk', text:'(GMT+08:00) Krasnoyarsk'},
              {value: 'Kuala Lumpur', text:'(GMT+08:00) Kuala Lumpur'},
              {value: 'Perth', text:'(GMT+08:00) Perth'},
              {value: 'Singapore', text:'(GMT+08:00) Singapore'},
              {value: 'Taipei', text:'(GMT+08:00) Taipei'},
              {value: 'Ulaan Bataar', text:'(GMT+08:00) Ulaan Bataar'},
              {value: 'Urumqi', text:'(GMT+08:00) Urumqi'},
              {value: 'Irkutsk', text:'(GMT+09:00) Irkutsk'},
              {value: 'Osaka', text:'(GMT+09:00) Osaka'},
              {value: 'Sapporo', text:'(GMT+09:00) Sapporo'},
              {value: 'Seoul', text:'(GMT+09:00) Seoul'},
              {value: 'Tokyo', text:'(GMT+09:00) Tokyo'},
              {value: 'Adelaide', text:'(GMT+09:30) Adelaide'},
              {value: 'Darwin', text:'(GMT+09:30) Darwin'},
              {value: 'Brisbane', text:'(GMT+10:00) Brisbane'},
              {value: 'Canberra', text:'(GMT+10:00) Canberra'},
              {value: 'Guam', text:'(GMT+10:00) Guam'},
              {value: 'Hobart', text:'(GMT+10:00) Hobart'},
              {value: 'Melbourne', text:'(GMT+10:00) Melbourne'},
              {value: 'Port Moresby', text:'(GMT+10:00) Port Moresby'},
              {value: 'Sydney', text:'(GMT+10:00) Sydney'},
              {value: 'Yakutsk', text:'(GMT+10:00) Yakutsk'},
              {value: 'New Caledonia', text:'(GMT+11:00) New Caledonia'},
              {value: 'Vladivostok', text:'(GMT+11:00) Vladivostok'},
              {value: 'Auckland', text:'(GMT+12:00) Auckland'},
              {value: 'Fiji', text:'(GMT+12:00) Fiji'},
              {value: 'Kamchatka', text:'(GMT+12:00) Kamchatka'},
              {value: 'Magadan', text:'(GMT+12:00) Magadan'},
              {value: 'Marshall Is.', text:'(GMT+12:00) Marshall Is.'},
              {value: 'Solomon Is.', text:'(GMT+12:00) Solomon Is.'},
              {value: 'Wellington', text:'(GMT+12:00) Wellington'},
              {value: 'Nuku alofa', text:'(GMT+13:00) Nuku alofa'},
              {value: 'Samoa', text:'(GMT+13:00) Samoa'},
              {value: 'Tokelau Is', text:'(GMT+13:00) Tokelau Is'}
            ]
  end


end

class ReportsController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@parkpointsoftware.com.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  include HomeHelper
  include ApplicationHelper #FIXME AMT
  include ReportsHelper
  include DealsHelper

  before_filter  :authenticate_admin

  #layout 'report' , :only => [:report_pdf]

  def index
      ##Know the current quarter
     #@title = "InSet CRM | Free CRM Tool | Sales Activity Report"
     @description = "InSet CRM the free crm tool activity details report of all CRM solutions."
     @current_quarter =  quarter_month_numbers Date.today
     @curr = "#{@current_quarter[0]}-#{Time.zone.now.year}"
     @quarter = @current_quarter[0].to_i
     @year = Time.zone.now.year
     if(@current_quarter == [1])
        @start_date = DateTime.new(Time.zone.now.year,1,1)
        @end_date = DateTime.new(Time.zone.now.year,3,31)
      elsif(@current_quarter == [2])
        @start_date = DateTime.new(Time.zone.now.year,4,1)
        @end_date = DateTime.new(Time.zone.now.year,6,30)
      elsif(@current_quarter == [3])
        @start_date = DateTime.new(Time.zone.now.year,7,1)
        @end_date = DateTime.new(Time.zone.now.year,9,30)
      elsif(@current_quarter == [4])
       @start_date = DateTime.new(Time.zone.now.year,10,1)
       @end_date = DateTime.new(Time.zone.now.year,12,31)
      end

#     @users = current_user.organization.users.includes(:user_role).where("users.admin_type not IN (?) ", [1,2]).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|
     @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

     t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
     t t

     }
    @users = @users.reverse

  end


  def get_funnel_chart
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    @start_date = get_start_end_date[0]
    @end_date = get_start_end_date[1]
    #deals_funnel_chart=Deal.includes(:deal_status).where("deals.deal_status_id IS NOT NULL").by_range(start_date,end_date).by_is_active.group("deal_statuses.original_id").count

    # deals_funnel_chart=Deal.includes(:deal_status).where(:organization_id=>@current_organization.id).where("deals.deal_status_id IS NOT NULL").by_range(start_date,end_date).group("deal_statuses.original_id").count



    # @new_deals = (wd=deals_funnel_chart.values_at(1).first).present? ? wd : 0
#    @qualified_deals = get_deal_status_count_within_four_weeks([2]).by_range(start_date,end_date).count
#    @lost_deals = get_deal_status_count_within_four_weeks([5]).by_range(start_date,end_date).count
#    @won_deals = get_deal_status_count_within_four_weeks([4]).by_range(start_date,end_date).count


    # @qualified_deals=(wd=deals_funnel_chart.values_at(2).first).present? ? wd : 0
    # @lost_deals=(ld=deals_funnel_chart.values_at(5).first).present? ? ld : 0
    # @won_deals=(wd=deals_funnel_chart.values_at(4).first).present? ? wd : 0
    #Funnel chart by quarterly
    @data=[]
    @stages=@current_organization.deal_statuses.where("name NOT IN (?) AND is_active=?", ["Won","Lost"],true).order("original_id")
    #[['Website visits', 15654],['Downloads', 4064]]
    @stages.each do |stage|
      @data << [stage.name, @current_organization.deals.where("(created_at >= ? AND created_at <= ?) AND deal_status_id=? AND is_active=? AND is_won IS NULL",@start_date,@end_date,stage.id,true).count]
    end
    @funnel_chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart({ type: 'funnel', marginRight: 70})
      #f.title({ text: 'Sales funnel', x: -50})
      #f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21'])
      f.plotOptions(
        series: {
          dataLabels: {
              enabled: true,
              format: '<b>{point.name}</b> ({point.y:,.0f})',
              color: 'black',
              softConnector: true
          },
          neckWidth: '10%',
          neckHeight: '-10%',
          height: '90%',

      })
      f.legend( { enabled: true })
      f.series({
        name: 'no',
        data: @data
       })
      end

     render :partial => "sales_funnel_chart"


  end

  def pie_tag_chart
    begin
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    @start_date = get_start_end_date[0].strftime('%Y-%m-%d')
    @end_date = get_start_end_date[1].strftime('%Y-%m-%d')
      @tag_datatable =  ActiveRecord::Base.connection.execute("Select tags.name as tag_name, Count(deals.id) as count,deal_statuses.name as deal_status,deal_status_id from deals inner join taggings,tags,deal_statuses where deals.organization_id = #{@current_organization.id} and deals.id = taggings.taggable_id and  deals.is_active=1 and deals.created_at between '#{@start_date}' and '#{@end_date}' and taggings.taggable_type='Deal' and tags.id = taggings.tag_id and deal_statuses.id = deals.deal_status_id Group by tag_id,deal_status_id,tags.name")
      @technologylist =  ActiveRecord::Base.connection.execute("Select tags.name as tag_name, Count(deals.id) as count from deals inner join taggings,tags,deal_statuses  where deals.organization_id = #{@current_organization.id} and deals.id = taggings.taggable_id and  deals.is_active=1 and deals.created_at between '#{@start_date}' and '#{@end_date}' and taggings.taggable_type='Deal' and tags.id = taggings.tag_id and deal_statuses.id = deals.deal_status_id Group by tag_id,tags.name order by count desc LIMIT 10")
      technology = []
      counts = []
      @technologylist.each do |d|
          technology << d[0]
      end
      technology = technology
      new_deals=[]
      qualified_deals=[]
      notqualified_deals=[]
      won_deals=[]
      lost_deals=[]
      junk_deals=[]
      technology.each do |tech|
        newd = @tag_datatable.select{|hash| hash[3] == @current_organization.incoming_deal_status().id && hash[0] == tech }
        qualifyd = @tag_datatable.select{|hash| hash[3] == @current_organization.qualify_deal_status().id && hash[0] == tech }
        notqualifyd = @tag_datatable.select{|hash| hash[3] == @current_organization.not_qualify_deal_status().id && hash[0] == tech }
        wond = @tag_datatable.select{|hash| hash[3] == @current_organization.won_deal_status().id && hash[0] == tech }
        lostd = @tag_datatable.select{|hash| hash[3] == @current_organization.lost_deal_status().id && hash[0] == tech }
        junkd = @tag_datatable.select{|hash| hash[3] == @current_organization.junk_deal_status().id && hash[0] == tech }
        new_deals << (!newd.present? ? 0 : newd[0][1])
        qualified_deals << (!qualifyd.present? ? 0 : qualifyd[0][1])
        notqualified_deals << (!notqualifyd.present? ? 0 : notqualifyd[0][1])
        won_deals << (!wond.present? ? 0 : wond[0][1])
        lost_deals << (!lostd.present? ? 0 : lostd[0][1])
        junk_deals << (!junkd.present? ? 0 : junkd[0][1])
      end
      if @current_user.is_admin?
        @pie_tag_chart  = LazyHighCharts::HighChart.new('bar') do |f|
          f.xAxis({categories: technology,title: {text: "Tags"}})
          f.series(:name=>"New Deals",:data=> new_deals)
          f.series(:name=>'Qualified',:data=> qualified_deals)
          f.series(:name=>'Lost',:data=> lost_deals)
          f.series(:name=>'Won',:data=> won_deals )
          f.series(:name=>'Not Qualified',:data=> notqualified_deals)
          f.series(:name=>'Junk',:data=> junk_deals)
                f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21','#FF3300', '#E74B3B' ])
                 f.title({ :text=>""})
                 f.legend({verticalAlign: 'bottom',
                          backgroundColor: 'white',
                          borderColor: '#CCC',
                          borderWidth: 1,
                          shadow: false
                      })
                f.options[:chart][:defaultSeriesType] = "bar"
                f.plot_options({:bar=>{:stacking=>"normal"}})
               end ## do end
            end #if end
    rescue
      @pie_tag_chart  = LazyHighCharts::HighChart.new('bar')
    ensure
     render partial: "pie_tag_chart"
    end
  end


  def get_user_list_leaderboard
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    p "--------------start_date and end_date"
    p @start_date = get_start_end_date[0]
    p @end_date = get_start_end_date[1]
    #  @users = current_user.organization.users.includes(:user_role).where("users.admin_type not IN (?) ", [1,2]).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

    # t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
    # t t

    # }

     @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

     t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
     t t

     }
    @users = @users.reverse
     render :partial => "leaderboard_list"
  end


  def get_deals_won
    # get_start_end_date = get_start_date_and_end_date(params[:quarter])
    # @start_date = get_start_end_date[0]
    # @end_date = get_start_end_date[1]
    #get_start_and_end_date
    #@deals ||= get_deal_status_total_won([4],@start_date,@end_date) if @start_date.present? && @end_date.present?
    dealstages = []
    @lost_reason_count=[]
    @stack_users=[]
    get_start_and_end_date
    @org_lost_reasons = @current_organization.lost_reasons.map(&:reason)
    if params[:user_id] != "All"
      user = User.find_by_id params[:user_id]
      @users= @current_organization.active_users.map{|u|u.full_name.present? ? u.full_name : u.email.split("@")[0]}
      @won_deals = []
      @lost_deals = []
      @won_deals_count = user.deals.where("(created_at >= ? AND created_at <= ?) AND is_won=? AND is_active=?", @start_date, @end_date, true, true).count
      @lost_deals_count = user.deals.where("(created_at >= ? AND created_at <= ?) AND is_won=?", @start_date, @end_date, false).count
      @deals=user.deals.where("(created_at >= ? AND created_at <= ?) AND is_active=?",@start_date, @end_date, true)
      # @org_lost_reasons.each do |lost_reason|
      #   @lost_reason_count << user.deals.where("(created_at >= ? AND created_at <= ?) AND lost_reason=?",@start_date,@end_date,lost_reason).count
      # end
      @user_data = []
      @org_lost_reasons.each do |lost_reason|
        @user_data << user.deals.where("(created_at >= ? AND created_at <= ?) AND is_won=? AND lost_reason=?",@start_date,@end_date,false,lost_reason).count
      end
      @stack_users << {:name => user.full_name.present? ? user.full_name : user.email.split("@")[0], :data => @user_data}
    else
      user = nil
      @users=@current_organization.active_users.map{|u|u.full_name.present? ? u.full_name : u.email.split("@")[0]}
      @won_deals=@current_organization.active_users.map{|u|u.deals.where("(created_at >= ? AND created_at <= ?) AND is_won=? AND is_active=?",@start_date, @end_date, true, true).count}
      @lost_deals=@current_organization.active_users.map{|u|u.deals.where("(created_at >= ? AND created_at <= ?) AND is_won=?",@start_date, @end_date, false).count}
      @won_deals_count=0
      @lost_deals_count=0
      @deals=@current_organization.active_users.map{|u|u.deals.where("(created_at >= ? AND created_at <= ?) AND is_active=?",@start_date, @end_date, true)}
      # @org_lost_reasons.each do |lost_reason|
      #   @lost_reason_count << @current_organization.deals.where("(created_at >= ? AND created_at <= ?) AND lost_reason=?",@start_date,@end_date,lost_reason).count
      # end
      @current_organization.active_users.each do |user|
        @user_data = []
        @org_lost_reasons.each do |lost_reason|
          @user_data << user.deals.where("(created_at >= ? AND created_at <= ?) AND is_won=? AND lost_reason=?",@start_date,@end_date,false,lost_reason).count
        end
        @stack_users << {:name => user.full_name.present? ? user.full_name : user.email.split("@")[0], :data => @user_data}
      end
    end
    @stack_users = @stack_users.to_json
    #{id: 'animals',data: [['Cats', 4],['Dogs', 2],['Cows', 1],['Sheep', 2],['Pigs', 1]]}
    get_start_end_date = get_start_date_and_end_date(params[:selected_range])
    #SELECT COUNT(DISTINCT `deals`.`id`) FROM `deals` LEFT OUTER JOIN `deal_statuses` ON `deal_statuses`.`id` = `deals`.`deal_status_id` WHERE `deals`.`organization_id` = 1 AND (`deals`.`created_at` BETWEEN '2012-04-01 00:00:00' AND '2012-06-30 00:00:00') AND (deal_statuses.original_id IN (4) )
    
    render partial: "deals_won_list"
  end
  def get_opportunities
    get_start_and_end_date
    @type=params[:type]
    user = User.find_by_id params[:user_id]
    if params[:user_id] != "All"
      @deals = user.deals.where("(created_at >= ? AND created_at <= ?) AND is_won=? AND is_active=?", @start_date, @end_date, params[:type]=='won', true)
    else
      @deals = user.deals.where("(created_at >= ? AND created_at <= ?) AND is_won=? AND user_id=? AND is_active=?", @start_date, @end_date, params[:type]=='won', params[:user_id], true)
    end
    render partial: "won_lost_opportunities"
  end
  def activities_report
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    @start_date = get_start_end_date[0]
    @end_date = get_start_end_date[1]
    dealstages = []
    @activities_data = []
    @user_activities_data=[]
    get_start_and_end_date
    if params[:user_id] != "All"
      user = User.find_by_id params[:user_id]
      @users= []
      @stages=@current_organization.task_types.map(&:name)
      @current_organization.task_types.each do |task_type, activities|
        tasks=@current_organization.tasks.where("task_type_id=? AND (created_at >= ? AND created_at <= ?) AND (assigned_to=? OR created_by=?) AND is_completed=?", task_type.id, @start_date, @end_date, user.id, user.id, true)
        @user_activities_data << (tasks.present? ? tasks.count : 0)
      end
    else
      @stages=[]      
      @current_organization.task_types.each do |task_type, activities|
        user_data=@current_organization.active_users.map{|u|u.organization.tasks.where("task_type_id=? AND (created_at >= ? AND created_at <= ?) AND (assigned_to=? OR created_by=?) AND is_completed=?", task_type.id, @start_date, @end_date, u.id, u.id, true).count}
        @activities_data << {:name => task_type.name, :data => user_data}
      end
      @users=@current_organization.active_users.map{|u|u.full_name.present? ? u.full_name : u.email.split("@")[0]}
    end
    render partial: "activities_report"
  end
  def get_start_date_and_end_date quarter
      data=quarter.split("-")
      @curr = "#{data[0].to_i}-#{data[1].to_i}"
      @quarter = data[0].to_i
      @year = data[1].to_i
      case data[0]
      when "1"
        @start_date = DateTime.new(data[1].to_i,1,1)
        @end_date = DateTime.new(data[1].to_i,3,31)
      when "2"
        @start_date = DateTime.new(data[1].to_i,4,1)
        @end_date = DateTime.new(data[1].to_i,6,30)
      when "3"
        @start_date = DateTime.new(data[1].to_i,7,1)
        @end_date = DateTime.new(data[1].to_i,9,30)
      when "4"
         @start_date = DateTime.new(data[1].to_i,10,1)
         @end_date = DateTime.new(data[1].to_i,12,31)
      when "Past Week"
         @start_date = 1.week.ago.beginning_of_week
         @end_date = 1.week.ago.end_of_week
      when "This Week"
         @start_date = 0.week.ago.beginning_of_week
         @end_date = 0.week.ago.end_of_week
      when "Past Month"
         @start_date = 1.month.ago.beginning_of_month
         @end_date = 1.month.ago.end_of_month
      when "This Month"
         @start_date = 0.month.ago.beginning_of_month
         @end_date = 0.month.ago.end_of_month
      end
  return @start_date, @end_date
  end

  def report_pdf
     get_start_end_date = get_start_date_and_end_date(params[:quarter])
     @start_date = get_start_end_date[0]
     @end_date = get_start_end_date[1]
     if params[:url] == "get_leads_won"
      @deals ||= get_deal_status_total_won([4],@start_date,@end_date) if @start_date.present? && @end_date.present?
     elsif params[:url] == "get_user_list_leaderboard"
      @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|
       t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
       t t
       }
      @users = @users.reverse
     elsif params[:url] == "get_sales_analytic"
       @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|
       t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
       t t
       }
       @users = @users.reverse
     end
  end
def get_sales_analytic
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    @start_date = get_start_end_date[0]
    @end_date = get_start_end_date[1]
    #  @users = current_user.organization.users.includes(:user_role).where("users.admin_type not IN (?) ", [1,2]).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

    # t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
    # t t

    # }

     @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

     t = get_user_activity_count_for_leaderboard user, @start_date, @end_date

     }
    @users = @users.reverse
     render :partial => "sales_analytic"
  end
  def lead_age_bar_chart
  
    begin
      if params[:display_tab].present? && params[:display_tab] == "stage_progress"

        new_deal_piedonut = @current_organization.deal_transactions.group("deal_status_id").count
        p "-------------"
        p new_deal_piedonut
        p "-------------"
        dealstages = []
        stagecounts = []
        @current_user.organization.deal_statuses.where("name NOT IN (?)", ['won', 'lost']).order("original_id").each do |status|
          dealstages << status.name
          stagecounts << new_deal_piedonut.values_at(status.id).first
        end
      else
        lead_arr = []
        new_deal_piedonut=Deal.includes(:deal_status).where("deals.deal_status_id IS NOT NULL").where(deal_status_count_last_one_month(params[:quarter])).group("deal_statuses.original_id").count


       dealstages = []
        stagecounts = []
        @current_user.organization.deal_statuses.each do |status|
          dealstages << status.name
          stagecounts << new_deal_piedonut.values_at(status.original_id).first
        end
      end

       puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"

      if @current_user.is_admin?
       puts "&&&&&&&&&&&&&&&&&********************"
        @bar_tag_chart  = LazyHighCharts::HighChart.new('bar') do |f|
          #f.xAxis({categories: ['New Deals','Qualified','Lost','Won'],title: {text: "Deal Stages"}})
         # f.series(:data=> [new_chart,q_piedonut,l_piedonut,w_piedonut],:name=>'Total')
         f.xAxis({categories: dealstages,title: {text: "Deal Stages"}})
         f.series(:data=>stagecounts,:name=>'Total')
          # f.series(:name=>'Qualified',:data=> [10])
          # f.series(:name=>'Lost',:data=> [10])
          # f.series(:name=>'Won',:data=> [10] )
          # f.series(:name=>'Not Qualified',:data=> [10]) 
          # f.series(:name=>'Junk',:data=> [10])

                 f.title({ :text=>""})
                 f.legend({verticalAlign: 'bottom',
                          backgroundColor: 'white',
                          borderColor: '#CCC',
                          borderWidth: 1,
                          shadow: false
                      })
                f.options[:chart][:defaultSeriesType] = "bar"
                f.plot_options({:bar=>{:stacking=>"normal"},:colorByPoint=> true})
        end ## do end
      end #if end
    rescue
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!"
      @bar_tag_chart  = LazyHighCharts::HighChart.new('bar')
    ensure
     render partial: "lead_age_bar_chart"
    end
  end

  def get_lead_aging_view
    render :partial => "lead_aging_view"    
  end

  def lead_aging_chart
   begin
     @current_organization = @current_user.organization
      dealstages = {} # Hash for storing different statuses and associated ids of an organization.
      @current_organization.deal_statuses.where("name NOT IN (?) AND is_active=?", ["Won","Lost"],true).order('original_id asc').each do |status|
        dealstages[status.name] = status.id
      end
      # new_deal_piedonut = Deal.joins(deal_transactions: :deal_status).where("deals.is_won IS NULL AND deal_transactions.deal_status_id IS NOT NULL AND deals.organization_id = ? AND deal_statuses.name NOT IN (?) AND deal_statuses.is_active = ?", @current_organization.id, ["Won","Lost"],true).group("deal_statuses.id").order('deal_statuses.original_id asc').count

      # Array of chart's X axis elements
      range_names = ['0 to 7 days','8 to 15 days','16 to 30 days','31 to 60 days','61 to 120 days','> 120 days']
      @deals = {}
      @table_deals = {}
      dealstages.each do |status_name, status_id|
        if params[:user_id].present? && params[:user_id] != "All"
          status_deals = Deal.joins(deal_transactions: :deal_status).where("deals.is_won IS NULL AND deal_transactions.deal_status_id IS NOT NULL AND deals.organization_id = ? AND deal_statuses.name = ? AND deal_statuses.id = ? AND deal_statuses.is_active = ? AND deals.assigned_to =? AND deals.initiated_by =? AND deal_transactions.is_activity_display =?", @current_organization.id, status_name, status_id ,true, params[:user_id], params[:user_id],true).uniq("deals.id").order("deals.created_at desc")
        else
          status_deals = Deal.joins(deal_transactions: :deal_status).where("deals.is_won IS NULL AND deal_transactions.deal_status_id IS NOT NULL AND deals.organization_id = ? AND deal_statuses.name = ? AND deal_statuses.id = ? AND deal_statuses.is_active = ? AND deal_transactions.is_activity_display =?", @current_organization.id, status_name, status_id ,true,true).uniq("deals.id").order("deals.created_at desc")
        end
        v = []
        table_val = []
        range_hash = {} # hash to store the number of deals for each range for a particular status
        range_hash["0-7"] = 0
        range_hash["8-15"] = 0
        range_hash["16-30"] = 0
        range_hash["31-60"] = 0
        range_hash["61-120"] = 0
        range_hash[">120"] = 0
        status_deals.each do |deal|
          last_activity = get_deal_activity_stream_new(deal.id)
          last_activity_date = last_activity.first.created_at.to_date
          current_date = DateTime.now
          date_diff = (current_date - last_activity_date).to_i
          if date_diff >= 0 && date_diff <= 7
            range_hash["0-7"] = range_hash["0-7"] + 1
          elsif date_diff >= 8 && date_diff <= 15
            range_hash["8-15"] = range_hash["8-15"] + 1
          elsif date_diff >= 16 && date_diff <= 30
            range_hash["16-30"] = range_hash["16-30"] + 1
          elsif date_diff >= 31 && date_diff <= 60
            range_hash["31-60"] = range_hash["31-60"] + 1
          elsif date_diff >= 61 && date_diff <= 120
            range_hash["61-120"] = range_hash["61-120"] + 1
          else date_diff > 120
            range_hash[">120"] = range_hash[">120"] + 1
          end
        end
        v << range_hash["0-7"]
        v << range_hash["8-15"]
        v << range_hash["16-30"]
        v << range_hash["31-60"]
        v << range_hash["61-120"]
        v << range_hash[">120"]
        range_hash["total"] = v.inject(0){|sum,x| sum + x }
        table_val << range_hash["0-7"]
        table_val << range_hash["8-15"]
        table_val << range_hash["16-30"]
        table_val << range_hash["31-60"]
        table_val << range_hash["61-120"]
        table_val << range_hash[">120"]
        table_val << range_hash["total"]
        table_val << status_id
        if status_name.present?
          @deals[status_name] = v
          @table_deals[status_name] = table_val
        end
      end
      puts @table_deals.inspect
      check_values = []
      @deals.each do |k,v|
        puts "f.series(:data => " + v.to_a.to_s + ",:name=>" +k.to_s+")"
        check_values << v.to_a
      end
      if @current_user.is_admin?
        if check_values.flatten.all? {|aa| aa == 0}
          @bar_tag_chart  = ""
        else
          @bar_tag_chart  = LazyHighCharts::HighChart.new('column') do |f|
            f.xAxis({categories: range_names, title: {text: "Deal Stages"}})
            f.chart({:defaultSeriesType=>"column"})
            f.options[:chart][:defaultSeriesType] = "column"
            f.plot_options({:column=>{:stacking=>"normal"}})
            @deals.each do |k,v|
              f.series(:data=>v,:name=>k, showInLegend: true)
            end
            f.legend(verticalAlign: 'bottom',
                        backgroundColor: 'white',
                        borderColor: '#CCC',
                        borderWidth: 1,
                        shadow: false)
            f.title({ :text=>""})
          end
        end
      end
    rescue
      @bar_tag_chart  = LazyHighCharts::HighChart.new('column')
    ensure
     render partial: "lead_aging_chart"
    end
    
  end

  def lead_aging_popup_data
    @deals = []
    @status_deals_count = 0
    if params[:status_id].present? && params[:lead_count].present?
      @stage = DealStatus.find(params[:status_id])
      if @stage.present?
        if params[:user_id].present? && params[:user_id] != "All"
          @status_deals = Deal.joins(deal_transactions: :deal_status).where("deals.is_won IS NULL AND deal_transactions.deal_status_id IS NOT NULL AND deals.organization_id = ? AND deal_statuses.name = ? AND deal_statuses.id = ? AND deal_statuses.is_active = ? AND deals.assigned_to =? AND deals.initiated_by =? AND deal_transactions.is_activity_display =?", @current_organization.id, @stage.name, @stage.id ,true, params[:user_id], params[:user_id],true).uniq("deals.id").order("deals.created_at desc")
        else
          @status_deals = Deal.joins(deal_transactions: :deal_status).where("deals.is_won IS NULL AND deal_transactions.deal_status_id IS NOT NULL AND deals.organization_id = ? AND deal_statuses.name = ? AND deal_statuses.id = ? AND deal_statuses.is_active = ? AND deal_transactions.is_activity_display =?", @current_organization.id, @stage.name, @stage.id ,true,true).uniq("deals.id").order("deals.created_at desc")
        end
        if params[:lead_count] == "total"
          @deals = @status_deals
          @status_deals_count  = @deals.count
        else
          @status_deals.each do |deal|
            last_activity = get_deal_activity_stream_new(deal.id)
            last_activity_date = last_activity.first.created_at.to_date
            current_date = DateTime.now
            date_diff = (current_date - last_activity_date).to_i
            if params[:lead_count] == "0-7"
              if date_diff >= 0 && date_diff <= 7
                @deals << deal
              end
            elsif params[:lead_count] == "8-15"
              if date_diff >= 8 && date_diff <= 15
                @deals << deal
              end
            elsif params[:lead_count] == "16-30"
              if date_diff >= 16 && date_diff <= 30
                @deals << deal
              end
            elsif params[:lead_count] == "31-60"
              if date_diff >= 31 && date_diff <= 60
                @deals << deal
              end
            elsif params[:lead_count] == "61-120"
              if date_diff >= 61 && date_diff <= 120
                @deals << deal
              end
            elsif params[:lead_count] == ">120"
              if date_diff > 120
                @deals << deal
              end
            end
          end
          @status_deals_count  = @deals.length
        end
      end
    end
    render partial: "lead_aging_popup"
  end

  def get_lead_report
    puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

    begin
      new_deal_piedonut=Deal.includes(:deal_status).where("deals.deal_status_id IS NOT NULL").where(deal_status_count_last_one_month(params[:lead_range])).group("deal_statuses.original_id").count
      new_array = []
      @current_user.organization.deal_statuses.each do |status|
        dealhash = []
        dealhash << status.name
        dealhash << new_deal_piedonut.values_at(status.original_id).first
        new_array.push dealhash
      end
        @piedonut_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.chart({ type: 'pie', height:282})
        #f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21'])
        f.colors([ '#3497DB', '#F39C11','#2DCC70', '#E74B3C' ])
		    f.title({ text: ''})
        f.plotOptions({
          pie: { shadow: false}
        })
        f.series({
          name: 'Total:',
          data:
          #[
            #    ['New',    new_deal_piedonut.values.sum],
            #    ['Qualified',     (q_piedonut.nil? ? 0 : q_piedonut)],
		#		['Won',     (w_piedonut.nil? ? 0 : w_piedonut)],
           #     ['Lost',    (l_piedonut.nil? ? 0 : l_piedonut)]

            # ],
            new_array,
          size: '60%',
          innerSize: '20%',
          showInLegend:true,
          innerSize: '20%',
          showInLegend: true
         })
          f.legend({verticalAlign: 'bottom',
                      backgroundColor: 'white',
                      borderColor: '#CCC',
                      borderWidth: 1,
                      shadow: false
                  })
        end
    rescue
      @piedonut_chart = LazyHighCharts::HighChart.new('column')
   ensure
      render :partial => "lead_report"
    end

  end

  def get_stage_report
    begin
      get_start_and_end_date
      if params[:user_id].present? && params[:user_id] != "All"
        new_deal_piedonut = @current_organization.deal_transactions.where("user_id=? AND created_at >= ? AND created_at <= ? AND is_activity_display=?", params[:user_id], @start_date, @end_date,true).group("deal_status_id").count
        @deal_transactions = @current_organization.deal_transactions.includes(:deal_status).where("deal_transactions.user_id=? AND deal_transactions.created_at >= ? AND deal_transactions.created_at <= ? AND deal_transactions.is_activity_display=?", params[:user_id], @start_date, @end_date,true).order("deal_statuses.original_id").group_by(&:deal_status_id)
      else
        new_deal_piedonut = @current_organization.deal_transactions.where("created_at >= ? AND created_at <= ? AND is_activity_display=?", @start_date, @end_date,true).group("deal_status_id").count
        @deal_transactions = @current_organization.deal_transactions.includes(:deal_status).where("deal_transactions.created_at >= ? AND deal_transactions.created_at <= ? AND deal_transactions.is_activity_display=?", @start_date, @end_date, true).order("deal_statuses.original_id").group_by(&:deal_status_id)
      end
      dealstages = []
      stagecounts = []
      @current_user.organization.deal_statuses.where("name NOT IN (?)", ['won', 'lost']).order("original_id").each do |status|
        dealstages << status.name
        stagecounts << new_deal_piedonut.values_at(status.id).first
      end
      if @current_user.is_admin?
        if stagecounts.compact.present?
          @bar_tag_chart  = LazyHighCharts::HighChart.new('bar') do |f|
            f.xAxis({categories: dealstages,title: {text: "Deal Stages"}})
            f.series(:data=>stagecounts,:name=>'Total')
            f.title({ :text=>""})
            f.legend({verticalAlign: 'bottom',
                      backgroundColor: 'white',
                      borderColor: '#CCC',
                      borderWidth: 1,
                      shadow: false
                    })
            f.options[:chart][:defaultSeriesType] = "bar"
            f.plot_options({:bar=>{:stacking=>"normal"},:colorByPoint=> true})
          end
        else
          @bar_tag_chart  = ""
        end
      end
    rescue
      @bar_tag_chart  = LazyHighCharts::HighChart.new('bar')
    ensure
     render partial: "stage_progress"
    end
  end
  ##### Fetch contacted leads #####
  def contacted_leads
    begin
      if params[:date_from].present? && params[:date_to].present?
        @start_date = (params[:date_from].to_date + 1.day).beginning_of_day
        @end_date = params[:date_to].to_date.end_of_day
      else
        get_start_and_end_date
      end
      # new_deal_piedonut = @current_organization.deal_transactions.where("created_at >= ? AND created_at <= ?", @start_date, @end_date).group("deal_status_id").count
      @deal_transactions = @current_organization.deal_transactions.includes(:deal_status, :deal).where("deals.is_won IS NULL AND deals.is_webtolead = ? AND deals.is_active=? AND deal_transactions.created_at >= ? AND deal_transactions.created_at <= ?", true, true, @start_date, @end_date).order("deal_statuses.original_id").group_by(&:deal_status_id)
      @all_stages = @current_organization.deal_statuses.where("name NOT IN (?)", ['won', 'lost'])
      dealstages = []
      stagecounts = []
      @current_organization.deal_statuses.where("name NOT IN (?)", ['won', 'lost']).order("original_id").each do |status|
        dealstages << status.name
        stagecounts << @current_organization.deals.where("is_won IS NULL AND deal_status_id=? AND is_webtolead =?  AND is_active=? AND created_at >= ? AND created_at <= ?", status.id, true, true, @start_date, @end_date).count
      end
      @won_lost_stages = ["Won", "Lost"]
      dealstages << @won_lost_stages
      @won_lost_stages.each do |stage|
        if stage == "Won"
          @won_leads = @current_organization.deals.where("is_webtolead =? AND is_active=? AND is_won=? AND created_at >= ? AND created_at <= ?", true, true, true, @start_date, @end_date)
          stagecounts << @won_leads.count
        else
          @lost_leads = @current_organization.deals.where("is_webtolead =? AND is_active=? AND is_won=? AND created_at >= ? AND created_at <= ?", true, true, false, @start_date, @end_date)
          stagecounts << @lost_leads.count
        end
      end
      if @current_user.is_admin?
        @bar_tag_chart  = LazyHighCharts::HighChart.new('bar') do |f|
          f.xAxis({categories: dealstages.flatten,title: {text: "Deal Stages"}})
          f.series(:data=>stagecounts,:name=>'Total')
          f.title({ :text=>""})
          f.legend({verticalAlign: 'bottom',
                    backgroundColor: 'white',
                    borderColor: '#CCC',
                    borderWidth: 1,
                    shadow: false
                  })
          f.options[:chart][:defaultSeriesType] = "bar"
          f.plot_options({:bar=>{:stacking=>"normal"},:colorByPoint=> true})
        end
      end
    rescue
      @bar_tag_chart  = LazyHighCharts::HighChart.new('bar')
    ensure
     render partial: "contacted_leads"
    end
  end
  def get_stage_opportunities
    unless params[:quarter].present?
      get_start_and_end_date
      if params[:user_id] != "All"
        @deals = @current_organization.deal_transactions.where("deal_status_id =? AND user_id=? AND created_at >= ? AND created_at <= ? AND is_activity_display=?", params[:stage_id], params[:user_id], @start_date, @end_date,true).map{|dt| dt.deal if dt.deal.present? && dt.deal.is_active }
      else
        @deals = @current_organization.deal_transactions.where("deal_status_id =? AND created_at >= ? AND created_at <= ? AND is_activity_display=?", params[:stage_id], @start_date, @end_date,true).map{|dt| dt.deal if dt.deal.present? && dt.deal.is_active }
      end
    else
      get_start_end_date = get_start_date_and_end_date(params[:quarter])
      @start_date = get_start_end_date[0]
      @end_date = get_start_end_date[1]
      @deals = @current_organization.deals.where("is_won IS NULL AND is_active =? AND deal_status_id =? AND (created_at >= ? AND created_at <= ?)", true, params[:stage_id], @start_date, @end_date)
    end
    render partial: "stage_opportunities"
  end
  def get_contacted_leads_stage
    get_start_and_end_date
    @deals = @current_organization.deals.where("id IN (?)", params[:deal_ids])
    render partial: "contacted_leads_stage"
  end
  def get_start_and_end_date
    if(params[:selected_range] == "thisquarter" || params[:selected_range] == "lastquarter" ) 
      @curr_quarter =  get_month_quarter Date.today
      if params[:selected_range] == "thisquarter"
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
    elsif params[:selected_range] == "thisweek"
      @start_date = 0.week.ago.beginning_of_week
      @end_date = 0.week.ago.end_of_week
      
    elsif params[:selected_range] == "lastweek"
      @start_date = 1.week.ago.beginning_of_week
      @end_date = 1.week.ago.end_of_week
    
    elsif params[:selected_range] == "thismonth"
      @start_date = 0.month.ago.beginning_of_month
      @end_date = 0.month.ago.end_of_month
    elsif params[:selected_range] == "lastmonth"
      @start_date = 1.month.ago.beginning_of_month
      @end_date = 1.month.ago.end_of_month

    elsif params[:selected_range] == "thisyear"
        @start_date = 0.year.ago.beginning_of_year
        @end_date = 0.year.ago.end_of_year
    elsif params[:selected_range] == "lastyear"
        @start_date = 1.year.ago.beginning_of_year
        @end_date = 1.year.ago.end_of_year
    end
  end
end

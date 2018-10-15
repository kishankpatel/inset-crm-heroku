require 'spreadsheet'
class HomeController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@parkpointsoftware.com.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/
  
  require 'net/http'
  include HomeHelper
  include TasksHelper
  include ApplicationHelper #FIXME AMT
  include DealsHelper
  include HotLeadAssignment
   
  skip_before_filter  :authenticate_user!, :only => [:index, :pricing, :notfound, :terms, :privacy, :security,:contact_us, :clear_cache,:api_contact_us, :download_user, :features,:integration, :faq, :awards_and_recognitions, :about_us, :roadmap,:report_a_bug, :releases, :save_bug_report, :pricing, :sitemap, :lambda_test, :org_permission_form, :success_story, :success_story_ajay, :pricing_new, :pre_order_self_hosting, :email_bounce_notification, :health, :self_hosting_download_form, :download_self_hosting_package, :pricing_self_hosted, :free_download, :download_community_file, :setup_linux, :setup_windows, :setup_mac, :setup_docker, :customization, :google_calendar, :setup_centos, :community_installation_support, :how_it_works, :unsubscribe, :send_email_series, :send_daily_update_reminder_notification]  
  caches_action :terms,:privacy#, :security
  
  def index   
    #@title = "Free CRM Tool | Free Cloud CRM Software | Client Management Software"
    @description = "InSet CRM the best cloud CRM tool to streamline sales, manage leads, establish better customer relationships and improve the productivity. Sign up free to #1 rank CRM Tool."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups, zoho alternatives, alternative to insightly, alternative to pipedrive, alternative to sugarcrm."
    if !params[:t].nil? || !params[:t].blank?
      if BetaAccount.exists?(:invitation_token => params[:t])
        buser = BetaAccount.find_by_invitation_token params[:t]
        @buser_email = buser.email if buser.email
      end
    end  
  end
  
  
  def dashboard
    if @current_user.is_siteadmin?
      redirect_to "/organizations"
    else  
      begin
        @filter_type = "This Month"
        if params[:filter_type].present?
          where = build_where_clause
          task_where = build_task_where_clause
        else
          where = "(updated_at >= '#{Time.zone.now.beginning_of_month}' and updated_at <= '#{Time.zone.now.end_of_month}')"
          task_where = "(tasks.updated_at >= '#{Time.zone.now.beginning_of_month}' and tasks.updated_at <= '#{Time.zone.now.end_of_month}')"
        end
        if @current_user.is_admin? && (!params[:filter_user_id].present? || (params[:filter_user_id].present? && params[:filter_user_id] =='All' ) )
          #@tasks = @current_organization.tasks.order("updated_at desc")
          @tasks=@current_organization.tasks.where(where).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d')=? ", false, Time.zone.now.utc_offset, Time.zone.now.strftime("%Y/%m/%d"))
          @jobs=@current_organization.project_jobs.where(where).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d')=? ", false, Time.zone.now.utc_offset, Time.zone.now.strftime("%Y/%m/%d"))
          @upcoming_tasks=@tasks.where(where).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') > ?", false, Time.zone.now.utc_offset, Time.zone.now.strftime("%Y/%m/%d")).limit(5)
          count_condition=get_deal_status_count([1,2,3,4,5,6])
          #@new_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) and is_remote=? and deals.is_active=?", [1], false, true).count
          #@qualified_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) and is_remote=? and deals.is_active=?", [2], false, true).count
          #@won_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) and is_remote=? and deals.is_active=?", [5], false, true).count
          #@lost_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) and is_remote=? and deals.is_active=?", [6], false, true).count
          
          @new_ds=@current_organization.deal_statuses.where("name NOT IN (?)",["won", "lost"]).order("original_id").first
          @qualified_ds=@current_organization.deal_statuses.where("name NOT IN (?)",["won", "lost"]).order("original_id").second
          won_ds=@current_organization.deal_statuses.where("name=?","Won").first
          lost_ds=@current_organization.deal_statuses.where("name=?","Lost").first
          
          # @new_deals = @new_ds.present? ? @current_organization.deals.where(where).where(:is_active=>true,:deal_status_id=>@current_organization.filter_deal_status(@new_ds.id,@current_organization.id).id, :is_won => nil).count : 0
          @new_deals = @current_organization.deals.where(where).where("is_active=? AND is_won IS NULL",true).count
          @qualified_deals = @qualified_ds.present? ? @current_organization.deals.where(where).where(:is_active=>true,:deal_status_id=>@current_organization.filter_deal_status(@qualified_ds.id,@current_organization.id).id, :is_won => nil).count : 0
          @won_deals = @current_organization.deals.where(where).where(:is_won => true).count
          @lost_deals = @current_organization.deals.where(where).where(:is_won => false).count

          #@task_call_count = Task.last_three_months.task_list(current_user,nil,nil,nil,'Call').count
          @task_call_count = @current_organization.tasks.by_name('Call').where('tasks.organization_id=? AND tasks.is_completed=?',@current_organization.id, false).where(task_where).count
          @task_apointment_count = @current_organization.tasks.by_name('Appointment').where('tasks.organization_id=? AND tasks.is_completed=?',@current_organization.id, false).where(task_where).count
          @total_leads = @current_organization.deals.where(where).where(is_active: true).count
          
          @completed_tasks = @current_organization.tasks.by_is_completed.count
          @total_counts = @completed_tasks + @task_call_count + @total_leads + @won_deals + @lost_deals
          
          @cmpl_tasks_percentage = ((@completed_tasks.to_f/@total_counts.to_f)*100).round

          @call_percentage =  ((@task_call_count.to_f/@total_counts.to_f)*100).round

          @total_leads_percentage = ((@total_leads.to_f/@total_counts.to_f)*100).round

          @won_percentage = ((@won_deals.to_f/@total_counts.to_f)*100).round

          @lostdeal_percentage = ((@lost_deals.to_f/@total_counts.to_f)*100).round
          #flash[:bosuccess] = "<div class='bo-txt'>Your mail has been send successfully.We will contact you soon.</div>"   
          @four_weeks_leads = @current_organization.deals.where(where).order("updated_at desc").limit(7)
          begin 
            last_deal_condition=[]
            if (@current_user.is_admin? || @current_user.is_super_admin?)
              last_deal_condition.where("deals.organization_id =? AND deal_statuses.name =? AND deals.is_active=?", @current_user.organization_id, "won", true)
            else
              last_deal_condition.where(where).where("deals.organization_id =? AND deal_statuses.name =? AND deals.is_active=? AND (deals.assigned_to=? or initiated_by=?)", @current_user.organization_id, "won", true, @current_user.id, @current_user.id)
            end
            #@last_deal=@current_organization.deals.where(where).includes(:deal_status).select("deals.id, deals.created_at, deals.updated_at, deals.assigned_to, deals.deal_status_id").where(last_deal_condition).order("deals.updated_at desc").first
            if @current_user.is_admin?
              @last_deal = @current_organization.deals.where(where).where("is_won=?",true).last
            else
              @last_deal = @current_organization.deals.where(where).where("is_won=? and assigned_to=?",true,@current_user.id).last
            end
            if @last_deal.present?
               @last_closed_deal = @last_deal.present? ?  @last_deal : "Yet to close a deal."       
               #@last_closed_user = @last_deal.present? ?  @last_deal.closed_by_name : ""       
               
               close_deal_date = (deal_move = DealMove.by_deal_id_and_status_won(@last_deal.id, @last_deal.deal_status_id).first).present? ? deal_move.created_at.in_time_zone(@current_user.time_zone) : nil
               @last_close_deal_date = close_deal_date.present? ? close_deal_date.strftime("%Y").to_s == Time.zone.now.year.to_s ? close_deal_date.strftime("%b %d") : close_deal_date.strftime("%b %d, %Y") : "NA"
               #@ratio = Deal.avg_time_close_deal @current_user, @current_organization.id, 3.months.ago , Time.zone.now.tomorrow      
            
               #@last_closed_user = deal_move.present? && deal_move.user.present? && deal_move.user.full_name.present? ? deal_move.user.full_name : deal_move.user.email
            end
          rescue 
            @last_deal = nil

          end
        else
          filter_user_id = params[:filter_user_id].present? ? params[:filter_user_id] : @current_user.id
          @tasks=@current_organization.tasks.where(where).where("( created_by=? OR assigned_to=? )", filter_user_id, filter_user_id).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
          @jobs=@current_organization.project_jobs.where(where).where("( created_by=? OR assigned_to=? )", filter_user_id, filter_user_id).where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d')=? ", false, Time.zone.now.strftime("%Y/%m/%d"))
          @upcoming_tasks=@tasks.where(where).where("( created_by=? OR assigned_to=? ) AND is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?", filter_user_id, filter_user_id, false, Time.zone.now.strftime("%Y/%m/%d")).limit(5)
          count_condition=get_deal_status_count([1,2,3,4,5,6])

          @new_ds=@current_organization.deal_statuses.where("name NOT IN (?)",["won", "lost"]).order("original_id").first
          @qualified_ds=@current_organization.deal_statuses.where("name NOT IN (?)",["won", "lost"]).order("original_id").second
          won_ds=@current_organization.deal_statuses.where("name=?","Won").first
          lost_ds=@current_organization.deal_statuses.where("name=?","Lost").first
          
          #@new_deals = @new_ds.present? ? @current_organization.deals.where(where).where("(assigned_to=? )", filter_user_id).where(:is_active=>true,:deal_status_id=>@current_organization.filter_deal_status(@new_ds.id,@current_organization.id).id, :is_won => nil).count : 0
          @new_deals = @current_organization.deals.where(where).where("(assigned_to=? )", filter_user_id).where("is_active=? AND is_won IS NULL",true).count
          @qualified_deals = @qualified_ds.present? ? @current_organization.deals.where(where).where("(assigned_to=? )", filter_user_id).where(:is_active=>true,:deal_status_id=>@current_organization.filter_deal_status(@qualified_ds.id,@current_organization.id).id, :is_won => nil).count : 0
          @won_deals = @current_organization.deals.where(where).where("(assigned_to=? )", filter_user_id).where(:is_won => true).count
          @lost_deals = @current_organization.deals.where(where).where("(assigned_to=? )", filter_user_id).where(:is_won => false).count

          #@task_call_count = Task.last_three_months.where("( created_by=? OR assigned_to=? )", filter_user_id, filter_user_id).task_list(current_user,nil,nil,nil,'Call').count
          
          #@current_organization.tasks.where(where).where("( created_by=? OR assigned_to=? )", filter_user_id, filter_user_id)
          @task_call_count = @current_organization.tasks.by_name('Call').where('(tasks.assigned_to=? AND tasks.created_by=?) AND tasks.organization_id=? AND tasks.is_completed=? AND tasks.is_active=?',filter_user_id,filter_user_id,@current_organization.id, false, true).where(task_where).count
          @task_apointment_count = @current_organization.tasks.by_name('Appointment').where('(tasks.assigned_to=? AND tasks.created_by=?) AND tasks.organization_id=? AND tasks.is_completed=? AND tasks.is_active=?',filter_user_id,filter_user_id,@current_organization.id, false, true).where(task_where).count
          @total_leads = @current_organization.deals.where(where).where("(assigned_to=? ) AND is_active=?", filter_user_id, true).count
          
          @completed_tasks = @current_organization.tasks.by_is_completed.where('(tasks.assigned_to=? AND tasks.created_by=?)',filter_user_id,filter_user_id).count
          @total_counts = @completed_tasks + @task_call_count + @total_leads + @won_deals + @lost_deals
          
          @cmpl_tasks_percentage = ((@completed_tasks.to_f/@total_counts.to_f)*100).round

          @call_percentage =  ((@task_call_count.to_f/@total_counts.to_f)*100).round

          @total_leads_percentage = ((@total_leads.to_f/@total_counts.to_f)*100).round

          @won_percentage = ((@won_deals.to_f/@total_counts.to_f)*100).round

          @lostdeal_percentage = ((@lost_deals.to_f/@total_counts.to_f)*100).round
          #flash[:bosuccess] = "<div class='bo-txt'>Your mail has been send successfully.We will contact you soon.</div>"   
          @four_weeks_leads = @current_organization.deals.where(where).where("( assigned_to=? ) AND is_active=?", filter_user_id, true).order("created_at desc").limit(7)
          begin 
            last_deal_condition=[]
            if (@current_user.is_admin? || @current_user.is_super_admin?)
              last_deal_condition.where("deals.organization_id =? AND deal_statuses.name =? AND deals.is_active=?", @current_user.organization_id, "won", true)
            else
              last_deal_condition.where(where).where(" deals.organization_id =? AND deal_statuses.name =? AND deals.is_active=? AND (deals.assigned_to=?)", @current_user.organization_id, "won", true, filter_user_id)
            end
            #@last_deal=@current_organization.deals.where(where).includes(:deal_status).select("deals.id, deals.created_at, deals.updated_at, deals.assigned_to, deals.deal_status_id").where(last_deal_condition).order("deals.updated_at desc").first
            # if @current_user.is_admin?
            #   @last_deal = @current_organization.deals.where(where).where("is_won=?",true).last
            # else
            @last_deal = @current_organization.deals.where(where).where("is_won=? and assigned_to=?",true,filter_user_id).last
            #end
            if @last_deal.present?
               @last_closed_deal = @last_deal.present? ?  @last_deal : "Yet to close a deal."       
               #@last_closed_user = @last_deal.present? ?  @last_deal.closed_by_name : ""       
               
               close_deal_date = (deal_move = DealMove.by_deal_id_and_status_won(@last_deal.id, @last_deal.deal_status_id).first).present? ? deal_move.created_at.in_time_zone(@current_user.time_zone) : nil
               @last_close_deal_date = close_deal_date.present? ? close_deal_date.strftime("%Y").to_s == Time.zone.now.year.to_s ? close_deal_date.strftime("%b %d") : close_deal_date.strftime("%b %d, %Y") : "NA"
               #@ratio = Deal.avg_time_close_deal @current_user, @current_organization.id, 3.months.ago , Time.zone.now.tomorrow      
            
               #@last_closed_user = deal_move.present? && deal_move.user.present? && deal_move.user.full_name.present? ? deal_move.user.full_name : deal_move.user.email
            end
          rescue 
            @last_deal = nil
          end
        end
      rescue
        @tasks = []
        @jobs=[]
        @upcoming_tasks = []
        @new_deals=0
        @qualified_deals=0
        @won_deals=0
        @lost_deals=0
        @task_call_count=0
        @total_leads=0
        @completed_tasks=0
        @total_counts=0
        @cmpl_tasks_percentage=0
        @call_percentage=0
        @total_leads_percentage=0
        @won_percentage=0
        @lostdeal_percentage=0
        @last_deal = nil
        @task_call_count=0
        @task_apointment_count=0
        @four_weeks_leads=[]
      end

      #@tasks = tasks.limit(10)
      if @current_user.is_siteadmin?
        @users = User.order("updated_at desc")
      end
      # if @current_user.is_siteadmin?
      #   # Find users from users table instead of beta_accounts
      #   @users = User.order("updated_at desc")
      # end
      #@title = "InSet CRM | Free CRM Tool | User Dashboard"
      @description = "InSet CRM free CRM tool user dashboard is the place where user can check all his activities relating to sales and CRM solutions."
      if request.xhr?
        render :partial => 'dashboard_partial'
      end
    end
  end
  def unsubscribe
    password = "keysalt"
    unless params[:type].present? && (params[:type]=="IndividualContact" || params[:type]=="CompanyContact")
      @en = params[:user].gsub(" ",'+')
      @dcrypt = AESCrypt.decrypt(@en, password)
      @user = User.where("email=?",@dcrypt).first
      @user.update_attribute(:is_unsubscribe,true)
      @user.email_series.last.update_attribute(:is_unsubscribe,true)
    else
      @en = params[:contact].gsub(" ",'+')
      @dcrypt = AESCrypt.decrypt(@en, password)
      if params[:type]=="IndividualContact"
        @individual_contact = IndividualContact.where("email=?",@dcrypt).first
        @individual_contact.update_attribute(:is_unsubscribe,true)
      elsif params[:type]=="CompanyContact"
        @company_contact = CompanyContact.where("email=?",@dcrypt).first
        @company_contact.update_attribute(:is_unsubscribe,true)
      end
    end
  end
  def teams
    password = "keysalt"
    @dcrypt = ""
    begin
      @en = params[:invite].gsub(" ",'+')
      @dcrypt = AESCrypt.decrypt(@en, password)
    rescue
    end
    if @dcrypt.present? && @dcrypt == @current_user.email
      if @current_user.is_admin?
        redirect_to users_path
      else
        flash[:danger]="It seems like the link is not valid. Please contact suppor@parkpointsoftware.com"
        redirect_to "/"
      end
    else
      sign_out @current_user
      flash[:danger]="It seems like the link is not valid. Please contact suppor@parkpointsoftware.com"
      redirect_to "/"
    end
  end
  def build_where_clause
    where = ''
    where += ' AND ' unless where.empty?
    
    if(params[:filter_type] == "thisquarter" || params[:filter_type] == "lastquarter" ) 
      @curr_quarter =  get_month_quarter Date.today
      if params[:filter_type] == "thisquarter"
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
    end

    case params[:filter_type]
    when "thisweek"
      where += "#{where.present? ? 'and' : ''} (updated_at >= '#{0.week.ago.beginning_of_week}' and updated_at <= '#{0.week.ago.end_of_week}')"
      @filter_type = "This Week"
    when "lastweek"
      where += "#{where.present? ? 'and' : ''} (updated_at >= '#{1.week.ago.beginning_of_week}' and updated_at <= '#{1.week.ago.end_of_week}')"
      @filter_type = "Last Week"
    when "thismonth"
      where += "#{where.present? ? 'and' : ''} (updated_at >= '#{0.month.ago.beginning_of_month}' and updated_at <= '#{0.month.ago.end_of_month}')"
      @filter_type = "This Month"
    when "lastmonth"
      where += "#{where.present? ? 'and' : ''} (updated_at >= '#{1.month.ago.beginning_of_month}' and updated_at <= '#{1.month.ago.end_of_month}')"
      @filter_type = "Last Month"
    when "thisquarter"
      where += "#{where.present? ? 'and' : ''} (updated_at >= '#{@start_date}' and updated_at <= '#{@end_date}')"
      @filter_type = "This Quarter"
    when "lastquarter"
      where += "#{where.present? ? 'and' : ''} (updated_at >= '#{@start_date}' and updated_at <= '#{@end_date}')"
      @filter_type = "Last Quarter"
    when "thisyear"
      where += "#{where.present? ? 'and' : ''} (updated_at >= '#{0.year.ago.beginning_of_year}' and updated_at <= '#{0.year.ago.end_of_year}')"      
      @filter_type = "This Year"
    when "lastyear"
      where += "#{where.present? ? 'and' : ''} (updated_at >= '#{1.year.ago.beginning_of_year}' and updated_at <= '#{1.year.ago.end_of_year}')"
      @filter_type = "Last Year"
    end
    where
  end
def build_task_where_clause
    task_where = ''
    task_where += ' AND ' unless task_where.empty?
    case params[:filter_type]
    when "thisweek"
      task_where += "#{task_where.present? ? 'and' : ''} (tasks.created_at >= '#{Time.zone.now-1.week}' and tasks.created_at <= '#{Time.zone.now}')"
    when "lastweek"
      task_where += "#{task_where.present? ? 'and' : ''} (tasks.created_at >= '#{1.week.ago.beginning_of_week}' and tasks.created_at <= '#{1.week.ago.end_of_week}')"
    when "thismonth"
      task_where += "#{task_where.present? ? 'and' : ''} (tasks.created_at >= '#{Time.zone.now.beginning_of_month}' and tasks.created_at <= '#{Time.zone.now.end_of_month}')"
    when "lastmonth"
      task_where += "#{task_where.present? ? 'and' : ''} (tasks.created_at >= '#{1.month.ago.beginning_of_month}' and tasks.created_at <= '#{1.month.ago.end_of_month}')"
    when "thisyear"
      task_where += "#{task_where.present? ? 'and' : ''} (tasks.created_at >= '#{Time.zone.now-1.year}' and tasks.created_at <= '#{Time.zone.now}')"      
    when "lastyear"
      task_where += "#{task_where.present? ? 'and' : ''} (tasks.created_at >= '#{1.year.ago.beginning_of_year}' and tasks.created_at <= '#{1.year.ago.end_of_year}')"
    end
    task_where
  end
  def organizations
    if @current_user.is_siteadmin?
      @organizations = Organization.order("updated_at desc")
    end
    if request.format.csv?
      @organizations = @organizations
      if params[:filter_by_date].present? && params[:filter_by_date] != "All"
        set_date_range
        if params[:filter_by_plan].present? && params[:filter_by_plan] != "All"
          if params[:filter_by_plan] == "Pro plan"
            @organizations =  @organizations.includes(:user_subscriptions).where("organizations.id IN (?) AND (user_subscriptions.subscription_start_date >= ? AND user_subscriptions.subscription_start_date <= ?)", UserSubscription.all.map(&:organization_id), @start_date, @end_date)
          elsif params[:filter_by_plan] == "Trial"
            @organizations = @organizations.where("is_trial_expired=? AND (created_at >= ? AND created_at <= ?)",false, @start_date, @end_date)
          elsif params[:filter_by_plan] == "Trial Expired"
            @organizations = @organizations.where("is_trial_expired=? AND is_free_plan=? AND id NOT IN (?) AND (trial_expires_on >= ? AND trial_expires_on <= ?)", true, false, UserSubscription.all.map(&:organization_id), @start_date, @end_date)
          elsif params[:filter_by_plan] == "Free"
            @organizations = @organizations.where("is_free_plan=? AND (created_at >= ? AND created_at <= ?)",true, @start_date, @end_date)
          end
        else
          @organizations = @organizations.where("(created_at >= ? AND created_at <= ?)", @start_date, @end_date)
        end
      else
        if params[:filter_by_plan].present? && params[:filter_by_plan] != "All"
          if params[:filter_by_plan] == "Pro plan"
            @organizations =  @organizations.includes(:user_subscriptions).where("organizations.id IN (?)", UserSubscription.all.map(&:organization_id))
          elsif params[:filter_by_plan] == "Trial"
            @organizations = @organizations.where("is_trial_expired=?",false)
          elsif params[:filter_by_plan] == "Trial Expired"
            @organizations = @organizations.where("is_trial_expired=? AND is_free_plan=? AND id NOT IN (?)", true, false, UserSubscription.all.map(&:organization_id))
          elsif params[:filter_by_plan] == "Free"
            @organizations = @organizations.where("is_free_plan=?",true)
          end
        else
          @organizations
        end
      end
    end
    respond_to do |format|
      format.html
      format.json { render json: OrganizationsDatatable.new(view_context) }
      format.csv { send_data @organizations.to_csv, :filename => 'export-organizations-' + Time.zone.now.strftime("%Y%m%d%I%M%S").to_s + '.csv' }
    end
  end
  def get_organizations
    render :partial => "organization_listing"
  end
  def self_hosted_users
    if @current_user.is_siteadmin?
      @self_hosted_users = SelfHostingUser.order("updated_at desc")
    end
    respond_to do |format|
      format.html
      format.json { render json: SelfHostedUsersDatatable.new(view_context) }
    end
  end
  def self_hosting_download_form
    
  end
  def download_self_hosting_package
    self_hosted_user = SelfHostingUser.where("token=? AND unique_key=?", params[:token], params[:unique_key]).first
    if self_hosted_user.present?
      self_hosted_user.update_column :download_count, (self_hosted_user.download_count + 1)
      s3_name = "self_hosted_package/Wakeupsales-CRM-SelfHosted-Bundle.zip"
      signer = Aws::S3::Presigner.new
      signed_url = signer.presigned_url(:get_object, bucket: ENV['AWS_BUCKET'], key: s3_name, expires_in: 1800)
      #redirect_to signed_url
      render :js => "window.location = '#{signed_url}'"
      #redirect_to("https://wakeupsales.s3.amazonaws.com/self_hosted_package/CRM-Package.zip")
    else
      render text:"fail"
    end
  end
  def summary
    last_deal_condition=[]
    if (@current_user.is_admin? || @current_user.is_super_admin?)
      last_deal_condition.where("deals.organization_id =? AND deal_statuses.original_id IN (?) AND deals.is_active=?", @current_user.organization_id, [4], true)
    else
      last_deal_condition.where(" deals.organization_id =? AND deal_statuses.original_id IN (?) AND deals.is_active=? AND (deals.assigned_to=? or initiated_by=?)", @current_user.organization_id, [4], true, @current_user.id, @current_user.id)
    end
    @last_deal=@current_organization.deals.last_three_months.includes(:deal_status).select("deals.id, deals.created_at, deals.updated_at, deals.assigned_to, deals.deal_status_id").where(last_deal_condition).order("deals.updated_at desc").first
    if @last_deal.present?
       @last_closed_deal = @last_deal.present? ?  @last_deal : "Yet to close a deal."       
       @last_closed_user = @last_deal.present? ?  @last_deal.closed_by_name : ""       
       
      close_deal_date = (deal_move = DealMove.by_deal_id_and_status_won(@last_deal.id, @last_deal.deal_status_id).first).present? ? deal_move.created_at.in_time_zone(@current_user.time_zone) : nil
       @last_close_deal_date = close_deal_date.present? ? close_deal_date.strftime("%Y").to_s == Time.zone.now.year.to_s ? close_deal_date.strftime("%b %d") : close_deal_date.strftime("%b %d, %Y") : "NA"
       @ratio = Deal.avg_time_close_deal @current_user, @current_organization.id, 3.months.ago , Time.zone.now.tomorrow      
    end
    render partial: "summary"
  end
  
  def task_widget_page
    render partial: "home/widget_task_header"
  end
  
  def deal_statistics_info
    ##Deal statistics non-admin user
    @current_quarter =  quarter_month_numbers Date.today

    unless @current_user.is_super_admin? || @current_user.is_admin?
     current_quarter = get_current_quarter Date.today
     current_year = Time.zone.now.year
     case current_quarter
      when 1
        @start_date = DateTime.new(Time.zone.now.year,1,1)
        @end_date = DateTime.new(Time.zone.now.year,3,31)     
      when 2
        @start_date = DateTime.new(Time.zone.now.year,4,1)
        @end_date = DateTime.new(Time.zone.now.year,6,30)     
      when 3
        @start_date = DateTime.new(Time.zone.now.year,7,1)
        @end_date = DateTime.new(Time.zone.now.year,9,30)
      when 4
        @start_date = DateTime.new(Time.zone.now.year,10,1)
        @end_date = DateTime.new(Time.zone.now.year,12,31)     
      end
      @pportunity = Opportunity.find(:all, :conditions => ['user_id = ? AND year = ? AND quarter = ?',current_user.id,  current_year, current_quarter ])
      if @pportunity.present?
        if current_user.admin_type == 3 && current_user.role.present?
          @total_users = User.where("organization_id=? AND role_id=?", current_user.organization.id, current_user.role.id).count
          @above_rate_users = Opportunity.where("organization_id= ? AND user_id != ? AND year=? AND quarter = ? AND win > ?", current_user.organization.id, current_user.id,current_year, current_quarter, @pportunity.first.win ).count            
          @ratio = calculate_deals_rate @above_rate_users, @total_users
        end
      end
      @salescycle = SalesCycle.find(:all, :conditions => ['user_id = ? AND year = ? AND quarter = ?',current_user.id,  current_year, current_quarter ])
      if @salescycle.present?
        total_deals_quarter = SalesCycle.count(:all,:conditions=>['organization_id = ? and year = ? and quarter = ?',current_user.organization.id, current_year, current_quarter])
        sum = SalesCycle.sum(:average, :conditions => ['organization_id = ? and year = ? and quarter = ?', current_user.organization.id, current_year, current_quarter])
        @avg_days_for_all_deal = calcalute_avg_deal_org sum, total_deals_quarter
        if current_user.admin_type == 3 && current_user.role.present?
          @above_rate_users_sales_cycle = SalesCycle.where("organization_id= ? AND user_id != ? AND year=? AND quarter = ? AND average < ?", current_user.organization.id, current_user.id,current_year, current_quarter, @salescycle.first.average ).count     
          @ratio_salescycle = calculate_deals_rate @above_rate_users_sales_cycle, @total_users
          
        end
      end
    end
    render partial: "statistics_quarterly"
  end
  def set_date_range
    if(params[:filter_by_date] == "This Quarter" || params[:filter_by_date] == "Last Quarter" ) 
      @curr_quarter =  get_month_quarter Date.today
      if params[:filter_by_date] == "This Quarter"
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
    elsif params[:filter_by_date] == "This Week"
      @start_date = 0.week.ago.beginning_of_week
      @end_date = 0.week.ago.end_of_week
      
    elsif params[:filter_by_date] == "Last Week"
      @start_date = 1.week.ago.beginning_of_week
      @end_date = 1.week.ago.end_of_week
    
    elsif params[:filter_by_date] == "This Month"
      @start_date = 0.month.ago.beginning_of_month
      @end_date = 0.month.ago.end_of_month
    elsif params[:filter_by_date] == "Last Month"
      @start_date = 1.month.ago.beginning_of_month
      @end_date = 1.month.ago.end_of_month

    elsif params[:filter_by_date] == "This Year"
        @start_date = 0.year.ago.beginning_of_year
        @end_date = 0.year.ago.end_of_year   
    elsif params[:filter_by_date] == "Last Year"
        @start_date = 1.year.ago.beginning_of_year
        @end_date = 1.year.ago.end_of_year
    end
  end
  def line_chart_display
    begin
      if @current_organization.deals.first.present? 
        last_week_day = Time.zone.now
        weeks=[]
        months=[]
        new_deals=[]
        qualified_deals=[]
        won_deals=[]
        lost_deals=[]
        new_deals_count=[]
        close_deals_count=[]
        avg_close_deals_count=[]
        ## Calculating data for the deal statistics weekly basis
        4.times do
          weeks << last_week_day.strftime("%b %d")
          current_week_day= last_week_day - 1.week
          all_deals_weekly=get_deals_for_range(current_week_day, last_week_day)
          total_counts=@current_organization.deals.includes(:deal_status).select("deals.id, deals.created_at").where("deals.deal_status_id IS NOT NULL").where(all_deals_weekly).group("deal_statuses.original_id").count
          new_count = total_counts.values.sum
          # Deal.includes(:deal_status).select("deals.id, deals.created_at").where(all_deals_weekly).order("deals.created_at DESC").count
          close_count =total_counts.values_at(4).first
          close_count=0 if close_count.nil?
          # Deal.includes(:deal_status).select("deals.id, deals.created_at").where(all_deals_weekly).order("deals.created_at DESC").where("deal_statuses.original_id IN (?) ", [4]).count
          new_deals_count << new_count
          close_deals_count << close_count
          avg_close_deals_count << ((new_count != 0 && close_count != 0) ?  (new_count.to_i/close_count.to_i)/100 : 0)
          last_week_day = current_week_day
        end
        @deal_line_chart = LazyHighCharts::HighChart.new('graph') do |f|
           f.xAxis({categories: weeks.reverse,title: {text: "weeks"}})
           f.series(:name=> "New deals",:data=> new_deals_count.reverse)
           f.series(:name=> "Closed deals",:data=> close_deals_count.reverse)
           f.series(:name=> "Closed deal ratio",:data=> avg_close_deals_count.reverse)
           f.yAxis( title: { text: "Deals",align: 'high'}, labels: { overflow: 'justify'})
           f.legend({verticalAlign: 'bottom',
                    backgroundColor: 'white',
                    borderColor: '#CCC',
                    borderWidth: 1,
                    shadow: false
                })
           f.title({ :text=>" "})
		   f.options[:chart][:noData] = "Your custom message"
           # Options for Bar
           f.options[:chart][:defaultSeriesType] = "line"
        end
      end
    # rescue
      # @deal_line_chart = LazyHighCharts::HighChart.new('graph')
    ensure
      @deal_line_chart = LazyHighCharts::HighChart.new('graph')
      render partial: 'line_chart_display'
    end
  end
  

  def funnel_chart_display
    deals_funnel_chart=[] #Deal.includes(:deal_status).where(:organization_id=>@current_organization.id).where("deals.deal_status_id IS NOT NULL AND deal_statuses.is_active=? AND deal_statuses.is_visible =?",true,true).group("deal_statuses.name").count
    deal_statuses = @current_organization.deal_statuses.where({is_active: true, is_visible: true, is_funnel_view: true})
    ds ={}
    colors = []
    i = 0
    # arr = deal_statuses.map(&:name)
    # arr.each { |num| ds[num] = (ds[num] || 0) + 0 }
    deal_statuses.each do |deal_status|
      tab_deal = {deal_status.name => Deal.where("deal_status_id=?", deal_status.id).count}
      deals_funnel_chart << tab_deal
      colors << (deal_status.color.present? ? deal_status.color : DealsHelper::COLORS[i])
      i += 1
    end
    deal_statuses_for_funnel = ds.merge(deals_funnel_chart.reduce(:merge))
    #colors = deal_statuses_for_funnel.length.times.map{'#' + "%06x" % rand(0..0xffffff)}
    ds_array =[]
    deal_statuses_for_funnel.each do |key, value|
      ds_array << [key, value]
    end
    #{"New"=>0, "Qualified"=>0, "Not Qualified"=>0, "Quote"=>0, "Won"=>0, "Lost"=>0, "Returning"=>0, "Last"=>0, "overload"=>0, "break"=>1}
    @funnel_chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart({type: 'funnel', marginRight: 70})
      #f.title({ text: 'Sales funnel', x: -50})
      #f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21'])
      f.colors(colors)
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
      f.exporting({ enabled: false })
      f.legend({enabled: true})
      f.series({
                   name: 'count',
                   data: ds_array
               })
    end
    render :partial => "funnel_chart_display"
  end
  
  def pie_donut_chart
    begin
      new_deal_piedonut=@current_organization.deals.includes(:deal_status).where("deals.deal_status_id IS NOT NULL").where(deal_status_count_last_one_month).group("deal_statuses.original_id").count
      q_piedonut=new_deal_piedonut.values_at(2).first
      l_piedonut=new_deal_piedonut.values_at(5).first
      w_piedonut=new_deal_piedonut.values_at(4).first

      deal_statuses = @current_organization.deal_statuses

        @piedonut_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.chart({ type: 'pie', height:282})
        #f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21'])
        f.colors([ "#{deal_statuses[0].color.present? ? deal_statuses[0].color : '#3497DB' }", "#{deal_statuses[1].color.present? ? deal_statuses[1].color : '#F39C11' }", "#{deal_statuses[3].color.present? ? deal_statuses[3].color : '#2DCC70' }", "#{deal_statuses[4].color.present? ? deal_statuses[4].color : '#E74B3C' }" ])
		f.title({ text: ''})
        f.plotOptions({ 
          pie: { shadow: false}
        })
        f.series({
          name: 'Total:',
          data: [
                ["#{deal_statuses[0].name}",    new_deal_piedonut.values.sum],
                ["#{deal_statuses[1].name}",     (q_piedonut.nil? ? 0 : q_piedonut)],
				        ["#{deal_statuses[3].name}",     (w_piedonut.nil? ? 0 : w_piedonut)],
                ["#{deal_statuses[4].name}",    (l_piedonut.nil? ? 0 : l_piedonut)]
              ],
          size: '60%',
          innerSize: '20%',
          showInLegend:true
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
      render partial: "pie_donut_chart"
    end
  end

  def cumulative_signup_chart
    month_year = 1..12
    @all_month_sign_up_users = []
    month_year.each{|my| @all_month_sign_up_users << User.by_month_year(my,params[:filter_by].present? && params[:filter_by]=="Last Year" ? 1.year.ago.year : Time.now.year).count}
    i=0
    @cumulative_data = []
    sum_no = 0
    @all_month_sign_up_users.each do |n|
      if i > 0
        sum_no += n
        @cumulative_data << sum_no        
      else
        @cumulative_data << @all_month_sign_up_users[0]
        sum_no = @all_month_sign_up_users[0]
      end
      i += 1
    end
    @generate_data=[]
    pie_chart_data=[]
    total_users=0
    org_plans = Organization.all.group_by(&:get_plan)
    total_users = User.where("organization_id IS NOT NULL").count
    org_plans.each do |plan, org|
      users=0
      org.each do |o|
        users += o.users.count
      end
      @generate_data << {name: plan, y: ((users.to_f/total_users.to_f)*100).round(2)}
    end
    if request.xhr?
      render partial: "cumulative_signup_chart", :content_type => 'text/html'
    end
  end
  
  def load_header_count_section
    count_condition=get_deal_status_count([1,2,3,4,5,6])
    @new_deals = @current_organization.deals.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) and is_remote=? and deals.is_active=?", [1], false, true).count

    @working_deals = @current_organization.deals.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) AND is_current=? and is_remote=? and deals.is_active=? ", [1,2,3,4,5,6], true, false, true).count

    @qualified_deals = @current_organization.deals.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) and is_remote=? and deals.is_active=?", [2], false, true).count


    if badge_today.to_i > 0
      @task_count = badge_today
      @task_text="Today's tasks"
      @task_url = "/tasks?type=today"
    elsif badge_overdue.to_i > 0
      @task_count = badge_overdue
      @task_text="Overdue tasks"
      @task_url = "/tasks?type=overdue"
    elsif badge_upcoming.to_i > 0
      @task_count = badge_upcoming
      @task_text="Upcoming tasks"
      @task_url = "/tasks?type=upcoming"
    else
      @task_count = badge_all
      @task_text="Tasks"
      @task_url = "/tasks"
    end
    render partial: "load_header_count_section", :content_type => 'text/html'
  end
  
  
  def contact_us
    #@title = "Contact InSet CRM | Free CRM Tool | Lead Management Tool"
    @description = "Contact InSet CRM for free CRM Tool and lead management and customer management software. We will all types of support in installation and maintenance."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
    if request.post?
      build_contact_us_info(params[:email],params[:name],params[:comment], params[:need_help])
      Notification.contact_us_mail(params[:email],params[:name],params[:comment],params[:need_help]).deliver    
      if is_valid_user_email params[:email]  
        Notification.contact_us_mail_to_user(params[:email],params[:name]).deliver    
      end
      flash[:notice] = "Your mail has been send successfully.We will contact you soon."   
    end
  end
  
  def task_widget
    unless @current_user.is_super_admin? || @current_user.is_admin?
        @tasks=Task.includes(:deal).includes(:user).task_list(@current_user, params[:task_type], nil, 10) if @current_user.present?
        @task_type=params[:task_type] if params[:task_type].present?
        render partial: "widget_task_list", :content_type => 'text/html'
    else        
        admint = Task.where("(assigned_to=? )", @current_user.id) .includes(:deal).includes(:user).task_list_dashboard(@current_user, params[:task_type], nil, 10).order("assigned_to").group_by{|d| d.assigned_to} if @current_user.present?
        if admint.values.map(&:size)[0].to_i < 10        
             @non_admin_tasks=Task.where("(assigned_to != ? OR created_by != ?)", @current_user.id, @current_user.id) .includes(:deal).includes(:user).task_list(@current_user, params[:task_type], nil, 10-admint.values.map(&:size)[0].to_i).order("assigned_to").group_by{|d| d.assigned_to} if @current_user.present?
             @tasks =  admint.merge!(@non_admin_tasks)
        else
             @tasks = admint
        end
        @task_type=params[:task_type] if params[:task_type].present?
        render partial: "admin_widget_task_list", :content_type => 'text/html'
    end
    
    
  end
  
  def activities
    if @current_user.is_admin?
      @activities = activity_stream(@current_user.organization.id,params[:filter_user_id],params[:filter_duration], params[:filter_from],params[:filter_to]).first(2)
      #puts "##################33"
      #p @activities.first.class.name
      #render :json => @activities
      #@title = "InSet CRM | Free CRM Tool | User Activity"
      @description = "InSet CRM the free crm tool registered users can manage their activity easily."
      if request.xhr?
        @source="activities"
        render :partial=>"activity_all",:objects=>{source: @source}
      else
        respond_to do |format|
          format.html
          #format.json { render json: get_activities_json(activities) }
        end
      end
    else
      flash[:bodanger] = "You don't have sufficient permission to view this page."
      redirect_to root_path
    end

    

  end
  
  def get_activities
    if(params[:pagesource]=="dashboard")
      per_page = 10
    else
      per_page = 20
    end
    activities = activity_stream(@current_user.organization.id,params[:filter_user_id],params[:filter_duration], params[:filter_from],params[:filter_to],(params[:page]).to_i,per_page)
    render :json=>get_new_activities_json(activities)
  end
  
  def get_new_activities_json(activities)
    acts = []
    activities.each do |activity|
      id =0
      title=""
      created_by=""
      assigned_to =""
      due_date= nil
      created_at=nil
      attachment=nil
      is_complete = false 
      move_status =""
      created_by_id = 0
      note_att = 0
      url = ""
      actual_date = ""
      task_user_url = ""      
      activity_txt = ""
      activity_status_type = ""
      publish_status = false
      
      if(activity.activity_type == "Task")        
        if activity.activity_status == "Archive"
          activity_txt = "Archived Task"
          created_at=activity.activity_date
          title=activity.activity_desc
          created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
          created_by_id = activity.user.present? ? activity.user.id : "NA"
          actual_date = activity.activity_date.strftime("%I:%M %p")
          activity_status_type = activity.activity_status
        else
            task = Task.where(:id=> activity.activity_id).first        
            if task.present?
            id=activity.activity_id
            title=activity.activity_desc
            if activity.activity_status == "Create" || activity.activity_status == "Update" || activity.activity_status == "Complete"
               created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
               created_by_id = activity.user.present? ? activity.user.id : ""
               assigned_to=""
               task_user_url= ""
               activity_txt = activity.activity_status == "Create" ? "Created Task" : (task.is_completed == true ? "Completed Task" : "Updated Task")
            else
               created_by= task.initiator.present? ? (task.initiator.full_name.present? ? task.initiator.full_name : task.initiator.email) : "NA"
               created_by_id = task.initiator.present? ? task.initiator.id : "NA"
               assigned_to= activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"           
               encrypt_user = AESCrypt.encrypt(activity.user.id, "userid").gsub("/","-").strip.strip
               task_user_url= activity.user.present? ? "/profile/#{encrypt_user}" : "NA"
               activity_txt = "Created and Assigned Task"
            end        
            due_date = task.due_date.present? ? task.due_date.strftime("%a %d %b %Y @ %H:%M") : "NA"
            created_at=activity.activity_date
            is_complete = task.is_completed
            url=task.get_url        
            actual_date = activity.activity_date.strftime("%I:%M %p")
            active = task.taskable.is_active if task.taskable.present?
            activity_status_type = activity.activity_status
           end
         end
         
         if task.present? && task.taskable.present? 
             if task.taskable.class.name == "Deal"
               publish_status = task.taskable.is_public == false ? ((task.taskable.associated_users.include? @current_user.id) || ( @current_user.is_admin? ||  @current_user.is_super_admin?) || (task.user.id == @current_user.id) ? true : false) : true
             else
               publish_status = task.taskable.is_public == false ? ((@current_user.is_admin? || @current_user.is_super_admin?) || (@current_user.id == task.taskable.created_by) || (task.user.id == @current_user.id) ? true : false) : true
             end
         end
         
         
      end
      
      if(activity.activity_type == "Deal")
        deal = Deal.find_by_id activity.activity_id
        if deal.present?
          id=activity.activity_id
          title=activity.activity_desc        
          if activity.activity_status == "Create" || activity.activity_status == "Update" || activity.activity_status == "Archive"
            created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
            created_by_id = activity.user.present? ? activity.user.id : ""
            activity_txt = activity.activity_status == "Create" ? "Created Lead" : (deal.is_active == false ? "Archived Lead" : "Updated Lead")
            assigned_to= ""
          else
            created_by_user = @current_organization.users.where("id =?",activity.activity_by) if activity.activity_by.present?
            created_by_id = created_by_user.first.id if created_by_user.present?
            created_by = created_by_user.present? ? (created_by_user.first.full_name.present? ? created_by_user.first.full_name : created_by_user.first.email) : "NA"
            assigned_to= deal.assigned_user.present? ? deal.assigned_user.id : ""
            assigned_user= deal.assigned_user.present? ? (deal.assigned_user.full_name.present? ? deal.assigned_user.full_name : deal.assigned_user.email) : "NA"
            activity_txt = "Lead Assigned to User"
          end        
          created_at=activity.activity_date
          url = lead_path(deal)
          actual_date = activity.activity_date.strftime("%I:%M %p")
          active = deal.is_active
          activity_status_type = activity.activity_status
          if deal.is_public == false
             publish_status = ((deal.associated_users.include? @current_user.id) || ( @current_user.is_admin? ||  @current_user.is_super_admin?) ? true : false)
          else
             publish_status = true
          end
        end
      end

      if(activity.activity_type == "Project")
        project = Project.find_by_id activity.activity_id
        if project.present?
          id=activity.activity_id
          title=activity.activity_desc        
          if activity.activity_status == "Create" || activity.activity_status == "Update" || activity.activity_status == "Archive"
            created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
            created_by_id = activity.user.present? ? activity.user.id : ""
            activity_txt = activity.activity_status == "Create" ? "Created Project" : (project.is_archive ? "Archived Project" : "Updated Project")
            assigned_to= ""
          end        
          created_at=activity.activity_date
          url = project_project_jobs_path(project)
          actual_date = activity.activity_date.strftime("%I:%M %p")
          active = true
          activity_status_type = activity.activity_status
          publish_status = true
        end
      end

      if(activity.activity_type == "ProjectJob")
        project_job = ProjectJob.find_by_id activity.activity_id
        if project_job.present?
          id=activity.activity_id
          title=activity.activity_desc        
          if activity.activity_status == "Create" || activity.activity_status == "Update" || activity.activity_status == "Archive"
            created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
            created_by_id = activity.user.present? ? activity.user.id : ""
            activity_txt = activity.activity_status == "Create" ? "Created Project Job" : (project_job.is_archive ? "Archived Project Job" : "Updated Project Job")
            assigned_to= ""
          else
            created_by_user = @current_organization.users.where("id =?",activity.activity_by) if activity.activity_by.present?
            created_by_id = created_by_user.first.id if created_by_user.present?
            created_by = created_by_user.present? ? (created_by_user.first.full_name.present? ? created_by_user.first.full_name : created_by_user.first.email) : "NA"
            assigned_to= deal.assigned_user.present? ? deal.assigned_user.id : ""
            assigned_user= deal.assigned_user.present? ? (deal.assigned_user.full_name.present? ? deal.assigned_user.full_name : deal.assigned_user.email) : "NA"
            activity_txt = "Project Job Assigned to User"
          end        
          created_at=activity.activity_date
          url = project_project_job_path(project_job.project,project_job)
          actual_date = activity.activity_date.strftime("%I:%M %p")
          active = true
          activity_status_type = activity.activity_status
          publish_status = true
        end
      end
      
      
      if(activity.activity_type == "DealMove")
        dealmove = DealMove.find_by_id activity.activity_id
        id=activity.activity_id
        title=activity.activity_desc  
        created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
        created_at=activity.activity_date
        move_status=dealmove.deal_status.present? ? dealmove.deal_status.name : ""
        created_by_id = activity.user.id if activity.user.present?
        url=lead_path(dealmove.deal)
        actual_date = activity.activity_date.strftime("%I:%M %p")
        active = dealmove.deal.is_active
        activity_status_type = activity.activity_status
        activity_txt = ""
        if dealmove.deal.is_public == false
           publish_status = ((dealmove.deal.associated_users.include? @current_user.id) || ( @current_user.is_admin? ||  @current_user.is_super_admin?) ? true : false)
        else
           publish_status = true
        end
      end
      if(activity.activity_type == "IndividualContact")
        contact = IndividualContact.find_by_id activity.activity_id
        if contact.present?
          id=activity.activity_id
          #title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
          title=activity.activity_desc        
          created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
          created_at=activity.activity_date
          created_by_id = activity.user.id if activity.user.present?
          url="/individual_contact/#{contact.id}"
          actual_date = activity.activity_date.strftime("%I:%M %p")
          activity_status_type = activity.activity_status
          active = contact.is_active
          activity_txt = activity.activity_status == "Create" ? "Created Contact" : (activity.activity_status == "Archive" ? "Archived Contact" : "Updated Contact")
          publish_status = ((@current_user.is_admin? || @current_user.is_super_admin?) || (@current_user.id == contact.created_by) ? true : false)
        end
      end
      
      if(activity.activity_type == "CompanyContact")
        contact = CompanyContact.find_by_id activity.activity_id
        if contact.present?
          id=activity.activity_id
          #title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
          title = activity.activity_desc        
          created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
          created_at=activity.activity_date
          created_by_id = activity.user.id if activity.user.present?
          url="/company_contact/#{contact.id}"
          actual_date = activity.activity_date.strftime("%I:%M %p")
          activity_status_type = activity.activity_status
          active = contact.is_active
          activity_txt = activity.activity_status == "Create" ? "Created Contact" : (activity.activity_status == "Archive" ? "Archived Contact" : "Updated Contact")
          if contact.is_public == false
              publish_status = ((@current_user.is_admin? || @current_user.is_super_admin?) || (@current_user.id == contact.created_by) ? true : false)
          else
              publish_status = true
          end
        end
      end      
      if(activity.activity_type == "Note")
        note = Note.find_by_id activity.activity_id
        if note.present?
          note_a = NoteAttachment.find_by_note_id note.id 
          id=activity.activity_id
          title = activity.activity_desc        
          created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
          created_at=activity.activity_date
          #attachment= note.attachment.present? ? note.attachment.url : "null"
          attachment= note.attachment_urls.present? ? note.attachment_urls : "null"
          created_by_id = activity.user.id if activity.user.present?
          url=""
          actual_date = activity.activity_date.strftime("%I:%M %p")
          activity_status_type = activity.activity_status
          activity_txt = ""
          publish_status = true
        end
      end
      if(activity.activity_type == "MailLetter")
        mail_letter = MailLetter.find_by_id activity.activity_id
        if mail_letter.present?
          id=activity.activity_id
          if(!mail_letter.contact_info.nil?)
            url="/#{mail_letter.contact_info['contact_type'].to_s}/#{mail_letter.contact_info['contact_id'].to_s}"
          else
            url=""
          end
          if(!mail_letter.contact_info.nil?)
            contact_info =mail_letter.contact_info
            title = "Mail Sent to <a src='#{url}'>#{contact_info['full_name']}</a>"     
          else
            title ="Mail Sent to  " + mail_letter.mailto  
          end 
          created_by=activity.user.present? ? (activity.user.full_name.present? ? activity.user.full_name : activity.user.email) : "NA"
          created_at=activity.activity_date
          created_by_id = activity.user.id if activity.user.present?
          actual_date = activity.activity_date.strftime("%I:%M %p")
          activity_status_type = activity.activity_status
          activity_txt = mail_letter.subject 
          begin 
            txt = "<span class='grey_act' style='font-size:12px'><br/>"
            if activity.sent_email_opens.present?
                activity.sent_email_opens.each do |sent_email_open|
                  txt += "Opened at: #{sent_email_open.opened} <br/>"
                end
            end
            txt = txt + "</span>"
            activity_txt += txt
          rescue
          end
          publish_status = true
        end
      end
      if(created_by_id == @current_user.id)
        created_by = "me"
      end  
      #if publish_status == true
        acts << {
          type: activity.activity_type,
          id: id,
          title: title,
          created_by: created_by,
          assigned_to: assigned_to.present? ? AESCrypt.encrypt(assigned_to, "userid").gsub("/","-").strip : "",
          due_date: due_date,
          created_at: created_at,
          attachment: attachment,
          is_complete: is_complete,
          move_status: move_status,
          created_at_int: created_at.to_i,
          url: url,
          actual_date: actual_date,
          created_by_id: created_by_id.present? ? AESCrypt.encrypt(created_by_id, "userid").gsub("/","-").strip : "",
          active: active,
          task_pro_url: task_user_url,
          activity_status_type: activity_status_type,
          activity_txt: activity_txt,
          assigned_user: assigned_user
        }
      #end
    end
    return acts
  end
  
  
  
  
  
  def get_activities_json(activities)
    # activities << org.deals
     # activities << org.deal_moves
     # activities << org.contacts
     # activities << org.tasks
     # activities << org.attachments
    acts = []
    activities.each do |activity|
      id =0
      title=""
      created_by=""
      assigned_to =""
      due_date= nil
      created_at=nil
      attachment=nil
      is_complete = false 
      move_status =""
      created_by_id = 0
      url = ""
      actual_date = ""
      task_user_url = ""
      if(activity.name == "Organization")
        org = Organization.find activity.id
        id=org.id
        title=org.name
        #created_by=org.user.full_name
        created_at=org.created_at
        attachment= ""
        #created_by_id = org.id
        url=""
      end
      if(activity.name == "Task")
        task = Task.find activity.id
        id=task.id
        title=task.get_title
        created_by=task.initiator.present? ? task.initiator.first_name : ""
        assigned_to=task.user.present? ? task.user.full_name : ""
        due_date = task.due_date.present? ? task.due_date.strftime("%a %d %b %Y @ %H:%M") : ""
        created_at=task.created_at
        is_complete = task.is_completed
        created_by_id = task.initiator.present? ? task.initiator.id : ""
        url=task.get_url
        task_user_url="/profile/#{task.assigned_to}"
        actual_date = task.created_at.strftime("%I:%M %p")
        active = task.taskable.is_active
      end
      if(activity.name == "Deal")
        deal = Deal.find activity.id
        id=deal.id
        title=deal.title
        created_by=deal.initiator.first_name if deal.initiator.present?
        assigned_to=deal.assigned_user.full_name if deal.assigned_user.present?
        created_at=deal.created_at
        created_by_id = deal.initiator.id if deal.initiator.present?
        url=lead_path(deal)
        actual_date = deal.created_at.strftime("%I:%M %p")
        active = deal.is_active
      end      
      if(activity.name == "DealMove")
        dealmove = DealMove.find activity.id
        id=dealmove.id
        title=dealmove.deal.title
        created_by=dealmove.user.first_name if dealmove.user.present?
        created_at=dealmove.created_at
        move_status=dealmove.deal_status.name
        created_by_id = dealmove.user.id if dealmove.user.present?
        url=lead_path(dealmove.deal)
        actual_date = dealmove.created_at.strftime("%I:%M %p")
        active = dealmove.deal.is_active
      end
      if(activity.name == "IndividualContact")
        contact = IndividualContact.find activity.id
        id=contact.id
        #title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
        title = contact.full_name
        created_by= contact.initiator.present? ? contact.initiator.first_name : ""
        created_at=contact.created_at
        created_by_id = contact.initiator.present? ? contact.initiator.id : ""
        url="/individual_contact/#{contact.id}"
        actual_date = contact.created_at.strftime("%I:%M %p")
      end
      if(activity.name == "CompanyContact")
        contact = CompanyContact.find activity.id
        id=contact.id
        #title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
        title = contact.full_name
        created_by= contact.initiator.present? ? contact.initiator.first_name : ""
        created_at=contact.created_at
        created_by_id = contact.initiator.present? ? contact.initiator.id : ""
        url="/company_contact/#{contact.id}"
        actual_date = contact.created_at.strftime("%I:%M %p")
      end
      #if(activity.name == "Contact")
      #  contact = Contact.find activity.id
      #  id=contact.id
      #  title=contact.contact_type == "Company" ? "#{contact.name}" + ", " + "#{contact.full_name ? contact.full_name : ''}" : contact.full_name
      #  created_by=contact.initiator.full_name
      #  created_at=contact.created_at
      #  created_by_id = contact.initiator.id
      #  url=contact_path(contact)
      #  actual_date = contact.created_at.strftime("%I:%M %p")
      #end
      if(activity.name == "Note")
        note = Note.find activity.id
        id=note.id
        title=note.notes
        created_by=note.user.first_name if note.user.present?
        created_at=note.created_at
        attachment= note.note_attachments.attachment.present? ? note.note_attachments.attachment.url : "null"
        created_by_id = note.user.id if note.user.present?
        url=""
        actual_date = note.created_at.strftime("%I:%M %p")
      end
      if(created_by_id == @current_user.id)
        created_by = "me"
      end  
      acts << {
        type: activity.name,
        id: id,
        title: title,
        created_by: created_by,
        assigned_to: assigned_to,
        due_date: due_date,
        created_at: created_at,
        attachment: attachment,
        is_complete: is_complete,
        move_status: move_status,
        created_at_int: created_at.to_i,
        url: url,
        actual_date: actual_date,
        created_by_id: created_by_id,
        active: active,
        task_pro_url: task_user_url
      }
    end
    return acts
  end
  
  def get_deals_for_range(deal_status=[1,2,3,4,5,6], month_start_date, last_week_day)
    deals_range_condition=[]
    if @current_user.is_admin? || @current_user.is_super_admin?
      deals_range_condition.where("deals.organization_id=?", @current_user.organization_id)
#      total_deals=Deal.where("deals.organization_id=?", @current_user.organization_id)
    else
      deals_range_condition.where("(assigned_to = ? or initiated_by= ?) and deals.organization_id = ?", @current_user.id, @current_user.id, @current_user.organization.id)
#      total_deals =@current_user.my_deals
    end
      deals_range_condition.where("(DATE_FORMAT(DATE_ADD(deals.created_at, INTERVAL #{Time.zone.now.utc_offset} second), '%Y-%m-%d') between (?) AND (?))", month_start_date.strftime("%Y-%m-%d"), last_week_day.strftime("%Y-%m-%d"))
      deals_range_condition.where("(deals.assigned_to=?)", @current_user.id) unless (@current_user.is_admin? || @current_user.is_super_admin?)
#    deals=total_deals.includes(:deal_status).select("deals.id, deals.created_at").where("deal_statuses.original_id IN(?) AND (DATE_FORMAT(DATE_ADD(deals.created_at, INTERVAL #{Time.zone.now.utc_offset} second), '%Y-%m-%d') between (?) AND (?))", deal_status, month_start_date.strftime("%Y-%m-%d"), last_week_day.strftime("%Y-%m-%d"))
#    deals=deals.where("(deals.assigned_to=?)", @current_user.id) unless (@current_user.is_admin? || @current_user.is_super_admin?)
    deals_range_condition
  end
  
  
  def get_users_activity_count(start_date, end_date)
      activities=Task.find_by_sql("select count(*) count , created_by from ((select id,'Deal' as name,created_at,initiated_by created_by from deals where organization_id = ? AND initiated_by != ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'CompanyContact' as name,created_at,created_by from company_contacts where organization_id = ? AND created_by != ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'IndividualContact' as name,created_at,created_by from individual_contacts where organization_id = ? AND created_by != ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'DealMove' as name,created_at,created_by from notes where notable_type = 'DealMove' and organization_id = ? AND created_by != ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'Task' as name,created_at,created_by from tasks where organization_id = ? AND created_by != ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'Task' as name,updated_at as created_at,assigned_to created_by from tasks where is_completed=1 and organization_id = ? AND assigned_to != ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'Note' as name,created_at,created_by from notes where organization_id = ? AND created_by != ? AND created_at BETWEEN ? AND ?)
	UNION ALL
    (select id,'Mail' as name,created_at,mail_by created_by  from mail_letters where organization_id = ? AND mail_by != ? AND created_at BETWEEN ? AND ?)) activities
    group by created_by order by count(*) desc limit 4", @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date)
    activities
  end
  
  def get_current_user_activity_count(start_date, end_date)
    activities=Task.find_by_sql("select count(*) count , created_by from (select id,'Deal' as name,created_at,initiated_by created_by from deals where organization_id = ? AND initiated_by = ? AND created_at BETWEEN ? AND ?
    UNION ALL
    (select id,'CompanyContact' as name,created_at,created_by from company_contacts where organization_id = ? AND created_by = ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'IndividualContact' as name,created_at,created_by from individual_contacts where organization_id = ? AND created_by = ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'DealMove' as name,created_at,created_by from notes where notable_type = 'DealMove' and organization_id = ? AND created_by = ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'Task' as name,created_at,created_by from tasks where organization_id = ? AND created_by = ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'Task' as name,updated_at as created_at,assigned_to created_by from tasks where is_completed=1 and organization_id = ? AND assigned_to = ? AND created_at BETWEEN ? AND ?)
    UNION ALL
    (select id,'Note' as name,created_at,created_by from notes where organization_id = ? AND created_by = ? AND created_at BETWEEN ? AND ?)
	  UNION ALL
    (select id,'Mail' as name,created_at,mail_by created_by  from mail_letters where organization_id = ? AND mail_by = ? AND created_at BETWEEN ? AND ?)) activities group by created_by order by count(*) desc", @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date, @current_user.organization.id, @current_user.id, start_date, end_date)
    activities  
  end
  
 def usage
  usage = []
  unless (@current_user.is_admin? || @current_user.is_super_admin?)
     if @current_organization.won_deal_status().present?
	 owndeal =  @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.won_deal_status().id,:assigned_to=>@current_user.id).count
	 end
	 if @current_organization.lost_deal_status().present?
      lostdeal =  @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.lost_deal_status().id,:assigned_to=>@current_user.id).count
	 end 
     total_deals = @current_user.all_assigned_or_created_deals.where(:is_active=>true).count     
     call_cmpl = Task.joins(:task_type).where("task_types.name='Call' and task_types.organization_id=? and tasks.organization_id=? and tasks.is_completed=1 and tasks.assigned_to=? ",@current_organization.id,@current_organization.id,@current_user.id).count
     leadsnortured = @current_organization.deals.includes(:deal_status).where(:is_active=>true,:assigned_to=>@current_user.id).where("deal_statuses.original_id IN (?) ", [2,3,4,5,6]).count
  else
      owndeal =  @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.won_deal_status().id).count
      lostdeal =  @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.lost_deal_status().id).count
     total_deals = @current_organization.deals.where(:is_active=>true).count
     call_cmpl = Task.joins(:task_type).where("task_types.name='Call' and task_types.organization_id=? and tasks.organization_id=? and tasks.is_completed=1  ",@current_organization.id,@current_organization.id).count
     leadsnortured = @current_organization.deals.includes(:deal_status).where(:is_active=>true).where("deal_statuses.original_id IN (?) ", [2,3,4,5,6]).count   
  end 
  lostdeal = lostdeal.nil? ? 0 : lostdeal
  owndeal = owndeal.nil? ? 0 : owndeal
  task_cmpl = badge_completed
  
     usage = {
	 owndeal: owndeal,
	 lostdeal: lostdeal,
	 deals: total_deals,
	 task_cmpl: task_cmpl,
	 call_cmpl: call_cmpl,
	 leadsnortured: leadsnortured
	 }
	 render json: usage
  end
  
  def notfound
  end
  def features
    #@title = "Best Cloud CRM Features |  Features of InSet CRM"
    @description = "InSet CRM the best cloud CRM tool to streamline sales, manage leads, establish better customer relationships and improve the productivity with powerful CRM features."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups, free contact management software"
  end
  def how_it_works
    #@title = "How CRM Works | InSet CRM"
    @description = "InSet CRM, the best free CRM tool helps in streamlining the sales activities, manage leads, create powerful customer relationships and improve the productivity with CRM Solution."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups, free contact management software"
  end
  def fetch_notification_count
    @tnc= params[:tnc]
    render partial: "shared/notification_counts"
  end
  def getting_started
    # begin
    #   EmailVerifier.check(@current_user.email)
    # rescue
    #   redirect_to profile_path, flash: {notice: "Your email is not valid. Please provide a valid email id to send verification mail."}
    # end
    #@title = "Getting Started With InSet CRM | Free CRM Tool"
    @description = "Get started with InSet CRM free crm tool to manage your leads, clients, sales and other activities to improve the productivity."
  end
  def daily_updates
    if @current_user.is_admin?
      @deals = @current_organization.deals.where("is_won IS NULL")
      @individual_contacts = get_contacts_having_opportunity
    else
      flash[:bodanger] = "You don't have sufficient permission to view this page."
      redirect_to root_path
    end
  end  

  def clear_cache
      puts "---------------fragments"
      
     # fragment = "*#{fragment.to_s.split(':').last.gsub(')', '')}*"
      
      
     # p fragment_exist?("cache:views/user_menu_207/dcf3768d7d134837f070386fce46ce9d")
    #  p fragment_exist?("views/user_menu_#{@current_user.id}/*")
    #  p Rails.cache.get("cache:views/user_menu_207/dcf3768d7d134837f070386fce46ce9d")
      #expire_fragment("user_menu_#{@current_user.id}") if @current_user.present?
     # cache.increment "counter"
     # p cache.read "counter", :raw => true      # => "24"
     Rails.cache.clear
     expire_fragment("home_page_new_ui")
     expire_fragment("features")
     expire_fragment("how_it_works")
     expire_fragment("integrations")
     expire_fragment("pricing")
     expire_fragment("sign_in")
     expire_fragment("sign_up")
     expire_fragment("user_menu_#{@current_user.id}") if @current_user.present?
     expire_fragment("admin_true") #if fragment_exist?("admin_true")
     expire_fragment("admin_false") #if fragment_exist?("admin_false")
     expire_fragment("header_logo")
     expire_fragment("dashboard_menu")

      expire_fragment("header_right_menu_admin_true")
      expire_fragment("header_right_menu_admin_false")
      
      expire_fragment("user_menu_true}")
      

      expire_action :controller => "home", :action => 'terms'
      expire_action :controller => "home", :action => 'privacy'
      expire_action :controller => "home", :action => 'security'
      expire_action :controller => "home", :action => 'index'
      
      redirect_to "/"
  end
  
  def api_contact_us
   xml_start_node = "<message>"
   xml_end_node = "</message>"
   if (params[:email] != "") && (params[:name] != "") && (params[:message] != "") &&  (params[:phone] != "") 
      build_contact_us_info(params[:email],params[:name],params[:message], params[:phone], true)
      msg = xml_start_node +"<success>Successfully saved the contact us information.</success>"+ xml_end_node
   else
      msg = xml_start_node +"<error>Error while saving contact us information.</error>"+ xml_end_node
   end
   respond_to do |format|
      format.json  { render :json => Hash.from_xml(msg).to_json }  
   end
 end
  
  def send_latest_blog_mail
    #begin
     ##This page is not available now
     # source = 'http://blog.andolasoft.com/wp-admin/api.php'
     # resp = Net::HTTP.get_response(URI.parse(source))
     # data = resp.body
     # result = JSON.parse(data)
     # guid = result["guid"]
     # title = result["post_title"]
     # content = result["post_content"].gsub!(/\n/, '<br>').gsub! "<img", "<img style='max-width:800px !important;'"
     source = 'http://blog.wakeupsales.com/recentposts.php'
     resp = Net::HTTP.get_response(URI.parse(source))
     data = resp.body
     data[0]=''
     data[data.length - 1] = ''
     
     result = JSON.parse(data)
     
     guid = result[0]["permalink"]
     title = ActionView::Base.full_sanitizer.sanitize(result[0]["title"])
     content = ActionView::Base.full_sanitizer.sanitize(result[0]["content"])
     img_url = result[0]["imgurl"]
     send_all = params[:send_all].present? ? false : true
     LatestBlogNotification.perform("#{guid}","#{title}","#{content}","#{send_all}")
     respond_to do |format|
        format.html {redirect_to "/"}
        format.json  { render :json => "success"}  
     end
   #rescue=>ex
     # respond_to do |format|
        
    #    format.json  { render :json => {message: ex.message}}  
     #end
   #end
 end
 
 def download_user
    download_user = DownloadUser.create(params[:download_user])
    download_user.update_column(:ip_address,request.remote_ip)
    geo_location = Geocoder.search(request.remote_ip).first
    address = geo_location.present? ? (geo_location.address.present? ? geo_location.address : "N/A") : "N/A"
    if download_user.email
      Notification.send_email_to_downloader(download_user.name,download_user.email).deliver ### Send mail to user
      Notification.send_email_to_admin(download_user.name,download_user.email,address).deliver ### Send mail to admin
    end

    flash[:notice]="Thank you for interest to download InSet CRM Community Edition! Please use the Download link sent to your email."
    redirect_to "/"
  end
  def integration
    #@title = "Best CRM Software Integrations | Free Cloud CRM Tool | CRM for Startups"
    @description = "InSet CRM free cloud CRM tool has filled with bunch of latest integrations to manage sales, lead and customer. Sign up free to take the advantages of latest integrations."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups, best free crm software"
  end
  def terms
    #@title = "Free CRM Tool | Terms and Conditions | InSet CRM"
    @description = "InSet CRM the free crm tool general terms and conditions for user’s acknowledgement before using this tool."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
  end
  def privacy
    #@title = "InSet CRM |Lead Management and Free CRM Tool | Privacy Policy"
    @description = "InSet CRM the client management and lead management software applies Privacy Policy to all of its products and services."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
  end
  def security
    #@title = "InSet CRM |Best Cloud CRM Tool | Security"
    @description = "InSet CRM the free CRM tool conducts routine security audits by top notch experts in the industry. We use physical and technical safeguards to preserve the integrity and security of your information."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
  end
  def faq
    #@title = "Frequently Asked Questions about Cloud CRM Tool | InSet CRM"
    @description = "Clarify yourself here about Wakeupsales cloud CRM tool to adopt the smart and powerful lead management and client management software for your business."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
  end
  def send_feedback
    name = params[:name]
    email = params[:email]
    company = params[:company]
    desc = params[:description]
    Notification.send_feedback_to_user(name,email).deliver if is_valid_user_email(email)
    Notification.send_feedback_to_support(name,email,company,desc).deliver
    render text: "Success"
  end

  def save_feedback
    message = params[:message]
    organization = current_user.organization
    feedback = Feedback.new
    feedback.user_id = current_user.id
    feedback.organization_id = current_user.organization.id
    feedback.message = params[:message]
    feedback.rating = params[:rating]
    feedback.page = params[:feedback_page]
    if feedback.save
      Notification.send_feedback_notification(feedback).deliver
    end  
    render text: "Success"
  end
  def feedbacks    
    if @current_user.is_siteadmin?
      @feedbacks = Feedback.order("created_at desc")
    end
  end

  def awards_and_recognitions
    #@title = "InSet CRM | Free Cloud CRM Tool |Awards and Recognitions"
    @description = "InSet CRM is a great place to work and interact with customers and employees around the world. Awards and recognitions we received from various top sources to do better, every day"
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
  end
  def about_us
    #@title = "About InSet CRM | Free CRM Tool | Lead and Client Management Software"
    @description = "InSet CRM is the best free CRM tool to streamline the sales activities, manage leads, create powerful customer relationships. We have customized add-ons and Plugins to make your work easier."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
  end
  def roadmap
    #@title = "Free CRM Tool | Free CRM Software Roadmap | InSet CRM"
    @description = "InSet CRM is the best cloud CRM software to streamline the sales, manage leads and establish better customer relationships. Check the roadmap of free CRM tool."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups, best sales crm, crm software for small business"
  end
  def releases
    #@title = "InSet CRM CRM Software Updates | Best Free CRM for Startups"
    @description = "Here you will check all the new updates of InSet CRM CRM Software. Free lead management tool and client management software for startups and enterprise. Sign up free now"
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups, sales management software, sales crm software"
  end
  def report_a_bug
    #@title = "Lead Management Software Bug Report | Free CRM Tool | InSet CRM"
    @description = "InSet CRM CRM tool user can report any technical bugs to make Wakeupsales bug free for smooth operation to manage your sales, lead and customer."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
    @bug_report = BugReport.new
  end
  def get_keywords
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups."
  end
  # Save Bug Report and send email to User and support@parkpointsoftware.com
  def save_bug_report
    if request.xhr?  
    else  
      begin
        params[:bug_report] = params[:bug_report].merge(:platform => "Cloud")
        if bug_report = BugReport.create(params[:bug_report])
          Notification.send_bug_report_to_user(params[:bug_report][:name],params[:bug_report][:email]).deliver if is_valid_user_email(params[:bug_report][:email])
          Notification.send_bug_report_to_support(params[:bug_report][:name],params[:bug_report][:email],params[:bug_report][:bug_type], params[:bug_report][:comments]).deliver
          flash[:notice] = "Thanks for writing to us. Cheers!"
        else

        end
      rescue Exception => e
         flash[:error] = e.message
      end 
    end
    redirect_to "/report-a-bug"
  end
  def pricing
    #@title = "Free CRM Tool Cloud Plan & Self-Hosted Plans | InSet CRM"
    @description = "InSet CRM is a great place to work and interact with customers and employees around the world. We have customized integrations to make your work simple. Check our pricing details."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
  end
  def sitemap
    #@title = "Cloud CRM Software Sitemap | InSet CRM"
    @description = "Wakeupsales CRM Tool web sitemap for your convenience. We are consistently updating our pages according to user requirement and here you will get all the list pages currently in website."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups"
  end
  def success_story
    #@title = "InSet CRM CRM Success Story | Cloud CRM and CRM Software Success Story"
    @description = "Within a very short period of time Wakeupsales CRM Tool is able to satisfy some valuable customer over the world. Let’s have a look at their success story with Wakeupsales CRM tool."
    @keywords = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, client management software, customer management system, free lead management software, customer management software, crm customer relationship management, crm for small business, cloud crm, crm application, top crm software, lead tracking software, free crm tools, best crm tools, best crm for sales, free cloud crm software, Cloud CRM Tool, Free Cloud CRM Tool, Free Cloud CRM app, Self-hosted, CRM for startups, success story, Ajay Success Story"
  end
  def success_story_ajay
    #@title = "InSet CRM Tool Success Story | Ajay Success Story"
    @description = "free crm, crm tool, best crm tool, best crm app, free crm app, crm software, free crm tool, best free crm, free crm software, best crm software, cloud crm software, lead management tool, lead management app, client management tools, free lead management tool, lead management software, success story, Ajay Success Story"
    get_keywords
  end
  def pricing_new
    #@title = "Free CRM Tool Cloud Plan | InSet CRM"
    @description = "InSet CRM is a great place to work and interact with customers and employees around the world. We have customized integrations to make your work simple. Check our pricing details."
    get_keywords
  end
  def pricing_self_hosted
    #@title = "Free CRM Tool Self-Hosted Plans | InSet CRM"
    @description = "InSet CRM is a great place to work and interact with customers and employees around the world. We have customized integrations to make your work simple. Check our pricing details."
    get_keywords
  end
  # Save pre-order info and send email to user and support
  def pre_order_self_hosting
    @pre_order = PreOrder.new(params[:pre_order])
    if @pre_order.save
      begin
        Notification.pre_order_notifiation_to_user(@pre_order).deliver if is_valid_user_email(params[:pre_order][:email])
        Notification.pre_order_notifiation_to_support(@pre_order).deliver
        flash[:notice] = "Successfully Pre-Ordered the Wakeupsales CRM Self-Hosted Edition"
      rescue Exception => e
        p "Error: #{e.message}"
        flash[:alert] = "Oops! Something went wrong. Please contact us at support@parkpointsoftware.com for help."
      end
    end
    redirect_to "/pricing"
  end

  def email_bounce_notification
    #https://akhilkr.wordpress.com/2014/08/05/handle-email-bounce-in-amazon-ses-ruby-on-rails-sns/
    bounce_email_logger ||= Logger.new("#{Rails.root}/log/bounce_email_logger.log")
    bounce_email_logger.info("-------- Bounce Email Created at: ---"+ Time.now.to_s + "-----------")
    bounce_email_logger.info(params)
    bounce_email_logger.info(request.headers)
    amz_message_type = request.headers['x-amz-sns-message-type']
    amz_sns_topic = request.headers['x-amz-sns-topic-arn']
    bounce_email_logger.info(request.raw_post)
    if amz_message_type.to_s.downcase == 'subscriptionconfirmation'
      send_subscription_confirmation request.raw_post
      return
    end    

    bounce_email_logger.info(amz_message_type.to_s)
    if amz_message_type.to_s.downcase == 'notification'
      require 'json'
      json = JSON.parse(request.raw_post)
      begin
        json2 = JSON.load(json['Message'])
        type = json2['notificationType']
        bounce_email_logger.info(type)
        if type=='Bounce'
          bounce = json2['bounce']
          # bounce_email_logger.info("------------------------")
          # bounce_email_logger.info(json2['mail'])
          # bounce_email_logger.info("------------------------")
          # bounce_email_logger.info(json2['mail']['commonHeaders'])
          # bounce_email_logger.info("-----------subject-------------")
          # bounce_email_logger.info(json2['mail']['commonHeaders']['subject'])
          # bounce_email_logger.info("-----------subject-------------")
          subject = json2['mail']['commonHeaders']['subject']

          bouncerecps = bounce['bouncedRecipients']
          # Notification.email_bounce_notification(bouncerecps).deliver
          bouncerecps.each do |recp|
            # bounce_email_logger.info("-----------recp-------------")
            # bounce_email_logger.info(recp['emailAddress'])
            # bounce_email_logger.info("-----------recp-------------")
            email = recp['emailAddress']
            #here is bounced email update your database and mark as bounce
            user = User.find_by_email email
            if user.present?
              user.update_attribute("is_email_bounce", true)
              BounceEmail.create({:organization_id => user.organization_id, :recipient_email => email, :subject => subject, :json_response => json.to_s })
            else
              other_user = MailLetter.find_by_mailto email
              if other_user.present?
                BounceEmail.create({:organization_id => other_user.organization_id, :sender_email => other_user.mail_by, :recipient_email => other_user.mailto, :subject => subject, :json_response => json.to_s })
              else
                BounceEmail.create({:recipient_email => email, :subject => subject, :json_response => json.to_s })
              end
            end
            bounce_email_logger.info("------bounced email update your database and mark as bounce-")
          end
        end
      rescue Exception => e
        bounce_email_logger.info("--------------JSON parse error occured---------------->>>>")
        bounce_email_logger.debug(e.message)
        bounce_email_logger.info("<<<<<--------------JSON parse error occured----------------")
      end
    end    
    render :text => "success"
  end

  def send_subscription_confirmation(request_body)
    bounce_email_logger ||= Logger.new("#{Rails.root}/log/bounce_email_logger.log")
    bounce_email_logger.info("-------- send_subscription_confirmation at: ---"+ Time.now.to_s + "-----------")
    require 'json'
    json = JSON.parse(request_body)
    subscribe_url = json ['SubscribeURL']
    require 'open-uri'
    open(subscribe_url)
  end

  def list_companies
    if @current_user.is_admin?
      @companies = @current_organization.company_contacts.order("updated_at desc")
    else
      @companies = @current_organization.company_contacts.where("created_by=?", @current_user.id).order("updated_at desc")
    end
    respond_to do |format|
      format.html
      format.json { render json: ListCompaniesDatatable.new(view_context) }
    end
  end

  def generate_company_data
    company = @current_organization.company_contacts.where("id=?",params[:id]).first
    leads = company.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten#.deals.map(&:contacts_id).uniq.compact
    @leads=leads.map(&:contacts_id).uniq.compact
    if @leads.present?
      @contacts = company.individual_contacts.where("id NOT IN (?)",@leads)
    else
       @contacts = company.individual_contacts
    end
    render partial: "generate_company_data"
  end

  def get_company_details
    @company = @current_organization.company_contacts.find_by_id(params[:id])
    render partial: "display_company_details"
  end

  def subscription_test
    puts "--------------------------subscription"

    subscription = Braintree::Subscription.find('hj4g62') 
    p subscription.status

    fddddddddddddddd

     # result = Braintree::Customer.create(
     #          :first_name => 'John',
     #          :last_name => 'Cena',
     #          :email => 'ansuman.taria@andolasoft.co.in',
     #          :phone => '7896541230',
     #          :company => 'Andolasoft',
     #          :credit_card => {
     #            :number => '4111111111111111',
     #            :cardholder_name =>"Ansuman Taria",
     #            :expiration_date => "11/2018",
     #            :cvv => '123',
     #            :options => {
     #              :verify_card => true
     #            },
     #            :billing_address => {
     #              :company => "andola",
     #              :street_address => "tesst",
     #              :locality => "sdsd",
     #              :region => "sadsad",
     #              :postal_code => "78965",
     #              :country_code_alpha2 => "US"
     #            }         
     #          }
     #  ) 

     #<Braintree::SuccessfulResult customer:#<Braintree::Customer id: "21029397", company: "Andolasoft", email: "ansuman.taria@andolasoft.co.in", fax: nil, first_name: "Ansuman", last_name: "Taria", phone: "7896541230", website: nil, created_at: 2017-04-17 11:16:34 UTC, updated_at: 2017-04-17 11:16:34 UTC,

     #raintree::CreditCard token: "8r4kmy"
     #74417295
    #  result = Braintree::Subscription.create(
    #             :payment_method_token => '2sv8qt',
    #             :plan_id => 'rr9r',
    #             :price => '4001.20'
    #             # :trialDuration => $remain_free_trial_days,
    #             # :trialPeriod => true,
    #             # :trial_duration_unit => 'day',
    # )

    #  p result
    #subscription ID - 6tw3jw

    #result = Braintree::Customer.find('21029397')
    ##<Braintree::Customer id: "21029397", company: "Andolasoft", email: "ansuman.taria@andolasoft.co.in", fax: nil, first_name: "Ansuman", last_name: "Taria", phone: "7896541230", website: nil, created_at: 2017-04-17 11:16:34 UTC, updated_at: 2017-04-17 11:16:34 UTC

    # result = Braintree::Customer.update('21029397',
    #           :first_name => 'John',
    #           :last_name => 'Mathew',                        
    #   ) 
    # result = Braintree::Subscription.cancel("gv3myw")
    bt_signature_param = "gcvy7dq3jkdg57vf|76934dc2a82404a5084275757534a4047d2d71f4"
    bt_payload_param = ""
     webhook_notification = Braintree::WebhookNotification.parse(
        bt_signature_param, bt_payload_param
    )    

   # sample_notification = Braintree::WebhookTesting.sample_notification(
   #    Braintree::WebhookNotification::Kind::SubscriptionWentActive,
   #    "6tw3jw"
   #  )

   #  webhook_notification = Braintree::WebhookNotification.parse(
   #    sample_notification[:bt_signature],
   #    sample_notification[:bt_payload]
   #  )

    p webhook_notification #.subscription.id
    p webhook_notification.kind    
    p webhook_notification.subscription.status
    # p result
    # p result.success?     
    # p result.subscription.id

    #<Braintree::SuccessfulResult subscription:#<Braintree::Subscription:0xdee74a8 @gateway=#<Braintree::Gateway:0x9c8324c @config=#<Braintree::Configuration:0x9404fe4 @custom_user_agent=nil, @endpoint=nil, @http_open_timeout=60, @http_read_timeout=60, @logger=#<Logger:0xda5c064 @progname=nil, @level=1, @default_formatter=#<Logger::Formatter:0xda5c03c @datetime_format=nil>, @formatter=#<Logger::SimpleFormatter:0xda68d00 @datetime_format=nil>, @logdev=#<Logger::LogDevice:0xda5c014 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>>, 11:27:41 UTC, @updated_at=2017-04-18 11:59:42 UTC, @current_billing_cycle=1, @days_past_due=nil, @discounts=[], @failure_count=0, @first_billing_date="2017-04-17", @id="3r6pcr", @merchant_account_id="andolasoft", @never_expires=true, @next_bill_amount="20.00", 

    # subscription = Braintree::Subscription.find("b9njcr")  
    # p subscription.status #== 'Active'

    fdsffffffffffffffffffff
  end

  def reset_subscription
    @current_organization.transactions.destroy_all
    @current_organization.user_subscriptions.destroy_all
    @current_organization.update_attributes :current_sub_id => nil, :is_sub_active => false, :is_trial_expired => false,:current_user_limit => nil, :trial_expires_on => Time.now+2.days
    redirect_to "/users/pricing"
  end

  def lambda_test
    Notification.subscription_cancel("Lambda function exceuted").deliver
    render :text => "success"
  end

  

  def send_user_upgrade_request
    Notification.upgrade_users_to_admin(@current_organization, @current_user).deliver    
    Notification.upgrade_users_to_user(@current_organization, @current_user).deliver if is_valid_user_email
    render :text => "success"
  end

  def health
    render text: "Ok".html_safe, :layout => false
  end
  
  def org_billing_history
    @organization = Organization.where("id=?",params[:org_id]).first
    @trans = @organization.user_subscriptions.order("created_at desc")
    @current_sub = @organization.user_subscriptions.active.last
  end

  def download_invoice
    @organization = Organization.where("id=?",params[:id]).first
    @tran = @organization.transactions.where("invoice_id =?", params[:invoice_id]).first
    generate_invoice_pdf
    send_data @pd_invoice.render_pdf, :filename => "#{@tran.organization.name.gsub(' ','_')}_#{@tran.invoice_id}.pdf", :type => "application/pdf"
  end

  def generate_invoice_pdf
    Payday::Config.default.invoice_logo = "public/image/wus-all-in-one.png" #"public/WUS_logo.png"
    Payday::Config.default.company_name = "Andolasoft"
    Payday::Config.default.company_details = "2059 Camden Ave. #118\nSan Jose, CA - 95124, USA"
    @invoice_line_items=[]
    if @tran
      @pd_invoice = Payday::Invoice.new(:invoice_number => @tran.invoice_id, :bill_to => (@tran.user.full_name.present? ? @tran.user.full_name + "\n" : "") + @tran.user.email, :notes => 'This charge will appear on your credit card statement as "ANDOLASOFT INC".', :paid_at => @tran.created_at.strftime("%m-%d-%Y"), :tax_rate => "")
      @pd_invoice.line_items << Payday::LineItem.new(:price => @tran.amount, :quantity => 1.0, :description => "#{@tran.user_subscription.user_limit} user(s) - Monthly Subscription - #{@tran.created_at.strftime('%B %Y')}")
    end
  end
  def bounce_emails
    if @current_user.is_siteadmin?
      @bounce_emails = BounceEmail.order("updated_at desc")
    end
    respond_to do |format|
      format.html
      format.json { render json: BounceEmailsDatatable.new(view_context) }
    end
  end
  #Email series
  def email_series
    if @current_user.is_siteadmin?
      puts "================================"
      @email_series = EmailSeries.order("updated_at desc")
      p @email_series.count
      # @email_series = EmailSeries.all.group_by(&:email_sent_for)
    end
    respond_to do |format|
      format.html
      format.json { render json: EmailSeriesDatatable.new(view_context) }
    end
  end
    #create company
  def create_org
    # @cn_email = CompanyContact.where("email = ?",params[:email]).first if params[:email].present?
    # @cn_phn = Phone.where("phoneble_type = ? and phone_no = ?",'CompanyContact',params[:work_phone]).first if params[:work_phone].present?
    # cc=CompanyContact.new
    # cc.organization = current_user.organization
    # cc.name = params[:name]
    # cc.country_id = params[:country]
    # cc.work_phone = params[:work_phone]
    # cc.created_by = current_user.id
    # cc.email = params[:email]
    # cc.website = params[:website]
    # cc.company_strength_id = params[:company_strength]
    
    # if @cn_email.present?
    #   msg = "Email"
    # elsif @cn_phn.present?  
    #   msg = "Phone"    
    # else    
    #   if cc.save
    #     if(params[:secondary_company].present? && params[:secondary_company] == 'true' && params[:referring_individual_contact].present?)
    #       puts "secondary_company reference found ................................"
    #       indi_contact = @current_organization.individual_contacts.where(:id=>params[:referring_individual_contact]).first
    #       if(indi_contact.company_contact.present?)
    #         puts "indi_contact found and creating secondary_company ................................"
    #         SecondaryCompany.create(:organization_id=>@current_organization.id,company_contact_id: cc.id,individual_contact_id: params[:referring_individual_contact])
    #       else
    #         puts "indi_contact found and adding  primary company ................................"
            
    #         indi_contact.company_contact_id = cc.id
    #         indi_contact.save
    #       end
    #     end
    #     Phone.create({organization_id: @current_organization.id, phone_no: params[:work_phone], phone_type: "work", phoneble_type: "CompanyContact", phoneble_id: cc.id})
    #     Address.create :organization => current_user.organization, :addressable => cc, :country_id=>params[:country], :city => params[:city], :state => params[:orgstate]
    #     msg = "save" 
    #     org_id = cc.organization_id
    #     activity_type = "Organization"
    #     activity_id = cc.id
    #     activity_user_id = cc.created_by
    #     activity_date = cc.created_at
    #     activity_desc = cc.full_name
    #     activity_status = "Create"
    #     Activity.create(:organization_id => org_id, :activity_user_id => activity_user_id, :activity_type => activity_type, :activity_id => activity_id, :activity_status => activity_status, :activity_desc => activity_desc, :activity_date => activity_date, :is_public => true, :source_id => activity_id)

    #     #flash[:notice] = "Company has been saved successfully"
    #   end
    # end
    # if(params[:secondary_company].present? && params[:secondary_company] == 'true')
    #   company_json_data = {id: cc.to_param, name: cc.name, company_size: cc.company_strength.present? ? cc.company_strength.range : "Not Available", contact_id:  indi_contact.id}
    #   render :json => {:status=>"success", :message=>msg,:company_json_data=>company_json_data}
    # else
    #   render :text=>msg
    # end
    create_company(params)
  end
  def create_org_wizard
    params[:company_contact][:work_phone] = params[:company_contact][:phones][:phone_no]
    params[:company_contact][:country] = params[:company_contact][:address][:country_id]
    params[:company_contact][:country] = params[:company_contact][:address][:country_id]
    params[:company_contact][:size_id] = params[:company_contact][:company_strength_id]
    create_company(params[:company_contact])

  end
  def create_company company_params
    p company_params
    begin
      puts " step 1 ......................."
      @cn_email = CompanyContact.where("email = ? and organization_id=?",company_params[:email],@current_user.organization_id).first if company_params[:email].present?
      @cn_phn = Phone.where("phoneble_type = ? and phone_no = ?",'CompanyContact',company_params[:work_phone]).first if company_params[:work_phone].present?
      cc=CompanyContact.new
      cc.organization = current_user.organization
      cc.name = company_params[:name]
      cc.country_id = company_params[:country]
      cc.work_phone = company_params[:work_phone]
      cc.created_by = current_user.id
      cc.email = company_params[:email]
      cc.website = company_params[:website]
      cc.company_strength_id = company_params[:size_id]
      puts " step 2 ......................."
      if @cn_email.present?
        msg = "Email"
      elsif @cn_phn.present?  
        msg = "Phone"    
      else    
        if cc.save
          puts " step 3 ......................."
          if(company_params[:secondary_company].present? && company_params[:secondary_company] == 'true' && company_params[:referring_individual_contact].present?)
            puts "secondary_company reference found ................................"
            indi_contact = @current_organization.individual_contacts.where(:id=>company_params[:referring_individual_contact]).first
            if(indi_contact.company_contact.present?)
              puts "indi_contact found and creating secondary_company ................................"
              SecondaryCompany.create(:organization_id=>@current_organization.id,company_contact_id: cc.id,individual_contact_id: company_params[:referring_individual_contact])
            else
              puts "indi_contact found and adding  primary company ................................"
              
              indi_contact.company_contact_id = cc.id
              indi_contact.save
            end
          end
          Phone.create({organization_id: @current_organization.id, phone_no: company_params[:work_phone], phone_type: "work", phoneble_type: "CompanyContact", phoneble_id: cc.id})
          Address.create :organization => current_user.organization, :addressable => cc, :country_id=>company_params[:country], :city => company_params[:city], :state => company_params[:orgstate] if( company_params[:orgstate].present?)
          if(company_params[:address].present?)
            Address.create :organization => current_user.organization, :addressable => cc, :country_id=>company_params[:address][:country_id], :city => company_params[:address][:city], :state => company_params[:address][:state] if( company_params[:address][:state].present?)
          
            
           
          end
          msg = "save" 
          org_id = cc.organization_id
          activity_type = "Organization"
          activity_id = cc.id
          activity_user_id = cc.created_by
          activity_date = cc.created_at
          activity_desc = cc.full_name
          activity_status = "Create"
          Activity.create(:organization_id => org_id, :activity_user_id => activity_user_id, :activity_type => activity_type, :activity_id => activity_id, :activity_status => activity_status, :activity_desc => activity_desc, :activity_date => activity_date, :is_public => true, :source_id => activity_id,:source_type=> cc.class.name)

          #flash[:notice] = "Company has been saved successfully"
        else
          puts " step 4 ......................."
          p cc.errors
          msg = cc.errors.messages
        end
      end
      if(company_params[:secondary_company].present? && company_params[:secondary_company] == 'true')
        company_json_data = {id: cc.to_param, name: cc.name, company_size: cc.company_strength.present? ? cc.company_strength.range : "Not Available", contact_id:  indi_contact.id}
        render :json => {:status=>"success", :message=>msg,:company_json_data=>company_json_data}
      else
        render :text=>msg
      end
    rescue => e
      p e.message
      render :json =>{status: "error",message: e.message}
    end
  end
  def connect_contact_to_company
    indi_contact = IndividualContact.where(:id=>params[:contact_id]).first
    comp_contact = CompanyContact.where(:id=>params[:company_contact_id]).first
    if(indi_contact.present?)
      if(! indi_contact.company_contact_id.present? )
        indi_contact.company_contact_id = comp_contact.id
        indi_contact.company_name= comp_contact.name
        indi_contact.save
      else
        # sc = SecondaryCompany.where(:individual_contact_id => indi_contact.id, company_contact_id: params[:company_contact_id]).first
        # if(!sc.present?)
          SecondaryCompany.create_or_skip(@current_organization.id, comp_contact.id, indi_contact.id)
          Activity.create(:organization_id => @current_organization.id, :activity_user_id => @current_user.id, :activity_type => "Organization", :activity_id => indi_contact.id, :activity_status => "Associate Company", :activity_desc => "Associated " + comp_contact.name + " with " + indi_contact.name, :activity_date => Date.today, :is_public => true, :source_id => indi_contact.id,:source_type => indi_contact.class.name)
        # end
      end
    end
    render :text=>"success"
  end
  def associate_org
    cc = CompanyContact.where(:id=>params[:asso_company_contact_id]).first
    if cc.present?
      if(params[:secondary_company].present? && params[:secondary_company] == 'true' && params[:referring_individual_contact].present?)
        puts "secondary_company reference found ................................"
        indi_contact = @current_organization.individual_contacts.where(:id=>params[:referring_individual_contact]).first
        if(indi_contact.company_contact.present?)
          puts "indi_contact found and creating secondary_company ................................"
          SecondaryCompany.create_or_skip(@current_organization.id, cc.id, params[:referring_individual_contact])
        else
          puts "indi_contact found and adding  primary company ................................"
          
          indi_contact.company_contact_id = cc.id
          indi_contact.save
        end
      end
    end
    company_json_data = {id: cc.to_param, name: cc.name, company_size: cc.company_strength.present? ? cc.company_strength.range : "Not Available",contact_id: indi_contact.id}
    render :js => "addMoreCompany(#{company_json_data.to_json})"
  end
  def deassociate_company
    indi_contact = IndividualContact.where(:id=>params[:contact_id]).first
    comp_contact = CompanyContact.where(:id=>params[:company_contact_id]).first
    if(indi_contact.present?)
      if(indi_contact.company_contact_id == params[:company_contact_id].to_i)
        indi_contact.company_contact_id = nil
        indi_contact.company_name=''
        indi_contact.save
      else
        sc = SecondaryCompany.where(:individual_contact_id => indi_contact.id, company_contact_id: params[:company_contact_id]).first
        if(sc.present?)
          sc.destroy
          Activity.create(:organization_id => @current_organization.id, :activity_user_id => @current_user.id, :activity_type => "Organization", :activity_id => indi_contact.id, :activity_status => "De-Associate Company", :activity_desc => "De-Associated " + comp_contact.name + " from " + indi_contact.name, :activity_date => Date.today, :is_public => true, :source_id => indi_contact.id,:source_type => indi_contact.class.name)
        end
      end
    end
    render :text=>"success"
  end
  def delete_organization
    org = Organization.where("id = ?", params[:id]).first
    if org.present?
      org.destroy
    end
    render :text => "success"
  end


 
  def download_community_file
    download_community_logger ||= Logger.new("#{Rails.root}/log/download_community_logger.log")
    begin
      download_community_logger.info("-------- Download community created at: ---"+ Time.now.to_s + "-----------")
      download_community_logger.info(params)
      download_community_logger.info("Remote IP: " + request.remote_ip)
      result = Geocoder.search(request.remote_ip)
      if result.first.present? 
        geo_code = result.first.data
      else
        geo_code = ""
      end
      if params[:email].present?
        Notification.community_download_notification_to_support(params[:name], params[:email], geo_code).deliver
        if is_valid_user_email(params[:email])
          Notification.community_download_notification_to_user(params[:name], params[:email]).deliver
          download_user = DownloadUser.new
          download_user.name = params[:name]
          download_user.email = params[:email]
          if geo_code.present?
            download_user.ip_address = geo_code["ip"] if geo_code["ip"].present?
            download_user.country_code = geo_code["country_code"] if geo_code["country_code"].present?
            download_user.country_name = geo_code["country_name"] if geo_code["country_name"].present?
            download_user.region_code = geo_code["region_code"] if geo_code["region_code"].present?
            download_user.region_name = geo_code["region_name"] if geo_code["region_name"].present?
            download_user.city = geo_code["city"] if geo_code["city"].present?
            download_user.zip_code = geo_code["zip_code"] if geo_code["zip_code"].present?
            download_user.time_zone = geo_code["time_zone"] if geo_code["time_zone"].present?
            download_user.latitude = geo_code["latitude"] if geo_code["latitude"].present?
            download_user.longitude = geo_code["longitude"] if geo_code["longitude"].present?
          end
          download_user.save
        end
      end
      render :text => "success"
    rescue Exception => e
      download_community_logger.debug(e.message)
      render :text => "fail"
    end
  end

  def setup_linux
    #@title="WakeupSales Community Edition Installation Process on Linux"
    @description="Step by step guide to install WakeupSales community edition on Linux. This free open source and flexible CRM web application has develop using Ruby on Rails."
    get_org_key_word
  end
  def setup_windows 
    #@title="WakeupSales Installation Process on Windows | Free CRM Tool"
    @description="Step by step guide process to describes you the installation of WakeupSales 0.10.1-rc2 with MySQL storage on Microsoft Windows VMs."
    get_org_key_word
  end
  def setup_mac
    #@title="WakeupSales Community Edition Installation Process on on Mac"
    @description="Step by step guide to install WakeupSales free open source and flexible CRM web application community edition on Mac developed using Ruby on Rails."
    get_org_key_word
  end
  def setup_docker
    #@title="WakeupSales Community Edition Installation Process on Docker"
    @description="Here one can get the step by step installation process of open source crm tool community edition in Docker and the basic system requirement."
    get_org_key_word
  end
  def customization
    #@title="Free Open Source CRM Tool | Community Edition Customize | InSet CRM"
    @description="Step by step guide to the customization of free open source crm tool community edition."
    get_org_key_word
  end
  def google_calendar
    #@title="Open Source CRM Tool | Google Calendar Installation Guide"
    @description="InSet CRM open source CRM tool is providing clear vision on Google calendar synchronization configuration guide here. One can easily use this in CRM tool."
    get_org_key_word
  end
  def setup_centos
    #@title="InSet CRM Opensource CRM Tool Installation Process on CentOS"
    @description="Step by step guide to install InSet CRM community edition on CentOS. This procedure describes the installation of InSet CRM CRM v4.0 with MySQL storage on CentOS. It works just fine with CentOS v7."
    get_org_key_word
  end
  def community_installation_support
    #@title="InSet CRM Tool Quick Installation and Support"
    @description="You will get quick installation and support from our experts to set everything up for, so that you can focus on your core business."
    get_org_key_word
  end
  def get_org_key_word
    @keywords="free open source crm software, open source crm tools, open source client management software, best open source crm software, open source free crm, open source crm application, open source lead management software, open source customer management system, free open source crm application, open source crm software, free open source crm Tool, Best open source crm Tool, open source best crm Tool, open source free crm tool, open source crm, simple open source crm, free open source free crm Application, open source lead management, best open source crm, open source sales crm, open source customer management, open source sales management."
  end
  #Send Email Series notification
  def send_email_series
    @email_series = @@email_series
    #@email_all = EmailSeries.includes(:user).where("users.is_email_bounce=?",false).order('id DESC').group_by { |r| r.user_id }
    @email_all = EmailSeries.includes(:user).where("users.is_email_bounce=? AND users.invitation_token IS NULL",false).order('email_series.id DESC').group_by { |r| r.user_id }
    begin
      @email_all.each do |d|
      @email_type = ""
      @email_duration = ""
      @interval=""
      @email_unsub = 'f'
      @email_series.each_with_index do |em,i|
        if em.include?d[1].first.email_sent_for
          i += 1
          @email_type  = @email_series[i][0]
          @email_duration  = @email_series[i][1]
          @interval  = @email_series[i][2]
          @user_plan  = @email_series[i][3]
          if d[1].first.is_unsubscribe?
            @email_unsub = 't'
          end
          break;
        end
      end
       email_type = @email_type
        if @email_unsub == 'f'
         case email_type
           when "Welcome Email"
             #@user = User.greetings_email d[1].first
           when "Getting Started"
             @user = User.pa_assit_email d[1].first, @email_duration, @interval, @user_plan
           when "Helpdesk"
             @user = User.pa_help_email d[1].first, @email_duration, @interval, @user_plan
           when "Activity Reminder"
             @user = User.first_act_email d[1].first, @email_duration, @interval, @user_plan
           when "Gmail Integration"
             @user = User.gmail_integration_email d[1].first, @email_duration, @interval, @user_plan
           when "Sales Pipeline"
             @user = User.sales_pipeline_email d[1].first, @email_duration, @interval, @user_plan
           when "Track Emails"
             @user = User.tracking_email d[1].first, @email_duration, @interval, @user_plan
           when "Invoice Management"
             @user = User.invoice_management_email d[1].first, @email_duration, @interval, @user_plan
           when "Manage Projects"
             @user = User.manage_projects_email d[1].first, @email_duration, @interval, @user_plan
           when "Website Leads"
             @user = User.website_leads_email d[1].first, @email_duration, @interval, @user_plan
           when "Set Goals"
             @user = User.set_goals_email d[1].first, @email_duration, @interval, @user_plan
           when "Trial Expire Week"
             @user = User.trial_expirewk_email d[1].first, @email_duration, @interval, @user_plan
           when "Premium Features"
             @user = User.pre_fea_email d[1].first, @email_duration, @interval, @user_plan
           when "Trial Expiring in 3 days"
             @user = User.trial_expr3_email d[1].first, @email_duration, @interval, @user_plan
           when "Extend Your Free Trial"
             @user = User.trial_extnd_email d[1].first, @email_duration, @interval, @user_plan
           when "Trial Expire Tomorrow"
             @user = User.trial_exprtm_email d[1].first, @email_duration, @interval, @user_plan
           when "Trial Over"
             @user = User.trial_ovr_email d[1].first, @email_duration, @interval, @user_plan
           when "No Paid Plan"
             @user = User.no_paid_email d[1].first, @email_duration, @interval, @user_plan
           when "After Trial Expiry"
             @user = User.after_trial_expiry d[1].first, @email_duration, @interval, @user_plan
           when "Feedback"
             @user = User.feedback_email d[1].first, @email_duration, @interval, @user_plan
           end
          end 
      end
    rescue
    end
    render :text => "Mail series completed."
  end
  #Daily update reminder
  def send_daily_update_reminder_notification
    @daily_update_reminder_logger = Logger.new('log/daily_update_reminder.log')
    daily_update_reminders = DailyUpdate.where("last_reminder_sent_at IS NULL OR last_reminder_sent_at < ?", Date.today)
    if daily_update_reminders.present?
      begin
        @daily_update_reminder_logger.info "+++++++++ Total daily update reminder #{daily_update_reminders.count} +++++++++"
        daily_update_reminders.each do |daily_update|
          assigned_users = daily_update.user_ids
          created_user = daily_update.user
          if assigned_users.present? && created_user.present? && daily_update.frequency.split(",").include?(Date.today.strftime("%a"))
            daily_update_timezone = daily_update.time_zone.present? ? daily_update.time_zone : "Kolkata"
            reminder_time = daily_update.alert_time.to_s(:time)
            @daily_update_reminder_logger.info "------------------- daily update reminder datetime"
            @daily_update_reminder_logger.info reminder_time
            @daily_update_reminder_logger.info Time.now.in_time_zone(daily_update_timezone).to_s(:time) + "----- In timezone #{daily_update.time_zone} and DailyUpdate ID: #{daily_update.id}"
            @daily_update_reminder_logger.info "------------------- current time"
            if (Time.now).in_time_zone(daily_update_timezone).to_s(:time) < reminder_time && ((Time.now + 5.minutes).in_time_zone(daily_update_timezone).to_s(:time) > reminder_time )
              Notification.send_daily_updates(assigned_users, daily_update.deal, daily_update.user, daily_update.recipient_ids).deliver
              daily_update.update_column :last_reminder_sent_at, Time.now.in_time_zone(daily_update_timezone)
              @daily_update_reminder_logger.info "----------- successfully sent daily update reminder notification #{assigned_users.split(',').map{|u| User.find_by_id(u).email}}"
            end
          end
        end
      rescue
      end
      @daily_update_reminder_logger.info "----------- Daily update reminder notification completed."
      render :text => "Daily update reminder notification completed."
    else
      @daily_update_reminder_logger.info "----------- Daily update not available"
      render :text => "Daily update not available"
    end
  end
  def list_notifications
    @all_notifications = @current_user.in_app_notifications.where("is_read=?",false).order("id desc").paginate(:page => params[:page], :per_page => 10)
  end
end


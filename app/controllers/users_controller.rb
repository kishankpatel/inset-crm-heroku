require 'validate_license'
require "spreadsheet"
class UsersController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@parkpointsoftware.com.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  include ApplicationHelper #FIXME AMT
  cache_sweeper :user_sweeper
  before_filter :authenticate_admin, :except => [:sign_up,:update_profile_image,:save_tmp_img, :get_user_email, :profile,:save_profile_info, :update, :save_password,:load_header_count_user, :invite_user, :assign_unassign_deals, :edit_user, :block_unblock_user, :grant_revoke_admin, :save_daily_updates, :manage_daily_updates, :edit_daily_update, :delete_daily_update, :assign_deal_to_user, :remove_lead, :get_users_dual_list, :update_active_inactive_users, :accept_social_invitation, :create_admin_user]
  before_filter :assign_user, :except => [:create_admin_user, :myplan, :update_license_key]
  skip_before_filter  :authenticate_user!, :only => [:sign_up, :accept_social_invitation, :create_admin_user]
  before_filter :can_invite_user, :only => [:invite_user]
  #before_filter :assign_license_key, :only => [:myplan, :invite_user, :update_license_key]

  def sign_up_old
    #@title = "Sign Up InSet CRM | Free CRM Tool and Client Management Software"
    @description = "InSet CRM has the facilities for new users to sign up for new account using their personal details. User can also sign up using Google+ and LinkedIn social accounts."
  end
  def sign_in_old
    #@title = "Sign In InSet CRM | Free CRM Tool and Client Management Software"
    @description = "Registered user can sign in to InSet CRM the free CRM tool using their personal credentials. User can also sign in using Google+ and LinkedIn social accounts."
  end
  def assign_user
     @user = current_user
     
  end
  
  def myplan
    @current_license = @current_organization.licensekey_info  
  end

  def invite_user
   user = User.where("email = ?", params[:user][:email]).first
   if !user.present?
    #begin

      user=User.new(params[:user])
      p user
      user.organization= @current_organization
      user.password = Devise.friendly_token[0,10]
      user.build_user_role(:role_id=> params[:user][:role_id], :organization_id => user.organization_id) if params[:user][:admin_type] == "3"
      respond_to do |format|
        # user.confirm!
        # user.skip_confirmation!
        if user.save 
          begin
			user.invite!(@user)		
			flash[:bosuccess]="Invitation email has been sent to the user."
		 rescue
			flash[:bowarning]="User was created successfully but invitation email can not send. Please configure your smtp settings."
		 end
          
          format.js  {render :nothing => true}
        else
          alert_msg=""
          msgs=user.errors.messages
          msgs.keys.each_with_index do |m,i|
            alert_msg=m.to_s.camelcase+" "+msgs[m].first
            alert_msg += "<br />" if i > 0
          end
         p alert_msg
        format.json { render json: user.errors, status: :unprocessable_entity }
        format.js {render text: alert_msg.to_s}
        end
      end
    # rescue => e
    #   p e.message
    #   flash[:bodanger]=e.message
    #   redirect_to "/dashboard"
    # end
  else
    if user.organization_id == @current_organization.id
     render text: "Email has already been taken!"
    else
      unless user.organization.present?
        user.organization = @current_organization
        user.admin_type = params[:user][:admin_type]
        user.first_name = params[:user][:first_name]
        user.last_name = params[:user][:last_name]
        user.build_user_role(:role_id=> params[:user][:role_id], :organization_id => user.organization_id) if params[:user][:admin_type] == "3"
        if user.save
          begin
			      user.invite!(@user)
      			flash[:bosuccess]="Invitation email has been sent to the user."
      		 rescue
      			flash[:bowarning]="User was created successfully but invitation email can not send. Please configure your smtp settings."
      		 end
          respond_to do |format|
            format.js  {render :nothing => true}
          end
        end
      else
        render text: "User is already invited by other organization!"
      end
    end
   end
  end

  def accept_social_invitation
    user=User.where("id=?",params[:id]).first
    unless user.present?
      redirect_to root_path
    else      
      user.invitation_token = nil
      user.invitation_accepted_at = Time.now
      user.save
      begin
        if request.host.include?("wakeupsales.com")
          result = Geocoder.search(request.remote_ip)
          Notification.mail_notification_to_support_for_accept_invitation(user, result).deliver
        end
      rescue
      end
      redirect_to user.provider == 'linkedin' ? '/auth/linkedin' : '/auth/google_oauth2'
    end
  end
  
  def edit
    @user=User.where("id=?",params[:id]).first
  end
  
  def update
    @user=User.where("id=?",params[:id]).first
        
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.update_column :role_id, params[:user][:role_id]
        expire_fragment("user_menu_#{@user .id}") #if fragment_exist?("user_menu_#{@user .id}")
        format.html { redirect_to request.referer, notice: 'User has been updated successfully.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def index
    if params[:id].present?
      @org = Organization.find(params[:id])
      @organization = @org
      @users =@org.users
    else
      #@users =current_user.organization.users.includes(:user_role).where("is_active =?", true).limit(50).order("users.admin_type, user_roles.role_id").group_by{|u| !u.first_name.nil? ?  u.first_name[0].upcase : ""}
      #@title = "InSet CRM | Free CRM Tool | Admin User"
      @description = "InSet CRM the free crm tool, admin section to manage all activities."
      #@users =current_user.organization.users.includes(:user_role).order("users.admin_type, user_roles.role_id").group_by{|u| !u.first_name.nil? && !u.first_name.blank? ?  u.first_name[0].upcase : ""}
      @users =@current_organization.users
    end
  end
  
  def destroy
    user = User.find(params[:id])
    #user.destroy
  user.update_column(:is_active,false)
    respond_to do |format|
      flash[:notice]="User successfully inactive."
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  def get_user_email
    respond_to do |format|
      format.json { render json: {email: User.find(params[:id]).email}}
    end
  end

  def assign_unassign_deals
    user = @current_organization.users.find_by_id(params[:user_id])
    if params[:assign_deal_ids].present?
      assign_deals = @current_organization.deals.where("id IN (?)", params[:assign_deal_ids].split(","))
      assign_deals.map {|d| d.update_attributes(assigned_to: user.id)   }
      #Notification.send_assign_unassign_mail(user,"assign",assign_deals)
    end
    if params[:unassign_deal_ids].present?
      unassign_deals = @current_organization.deals.where("id IN (?)", params[:unassign_deal_ids].split(","))
      unassign_deals.map {|d|
            d.update_attributes(assigned_to: current_user.id) 
            Activity.create(:organization_id => d.organization_id, :activity_user_id => d.initiated_by,:activity_type=> "Deal", :activity_id => d.id, :activity_status => "Removed",:activity_desc=>d.title,:activity_date => Time.zone.now, :is_public => true, :source_id => d.id,:activity_by => @current_user.id,:source_type=>d.class.name,:source_id => d.id)
          }
      #Notification.send_assign_unassign_mail(user,"unassign",unassign_deals)
    end    
    @users = @current_organization.users
    render :partial => "get_users"
  end

  def update_active_inactive_users
    respond_to do |format|      
      # puts "----------------update_active_inactive_users"
      # p params[:active_user_ids] #.split(",")

      # p params[:inactive_user_ids]
      # a = params[:active_user_ids].split(",")
      # i = params[:inactive_user_ids].split(",")

      # # p s.reject{|x| ids.include? x.id}

      # # p params[:active_user_ids].split(",") - params[:inactive_user_ids].split(",")
      # if @current_organization.trial_expired?       
      #   current_sub = @current_organization.user_subscriptions.last 
      #   if current_sub.present?
      #     if current_sub.user_limit.to_i == @current_organization.active_users.count        
      #         render :text => "Sorry, ", status: :unprocessable_entity 
      #         # render json: @user.errors, status: :unprocessable_entity 
      #         return false
      #     end
      #   else
      #     format.json { render json: "Sorry!!! we could not find any valid subscription.", status: :unprocessable_entity }
      #   end
      # end      
      if params[:inactive_user_ids].present?
        inactive_users = @current_organization.users.where("id IN (?)", params[:inactive_user_ids].split(","))
        inactive_users.update_all(is_active: false)
      end  
      if params[:active_user_ids].present?
        active_users = @current_organization.users.where("id IN (?)", params[:active_user_ids].split(","))
        active_users.update_all(is_active: true)
      end
      current_sub = @current_organization.user_subscriptions.last 
      if current_sub.present? && (current_sub.user_limit.to_i < @current_organization.active_users.count)
        @current_organization.users.where(["admin_type not in (?)", [1]]).update_all is_active: false
        #render :text => "Max allowed user: #{current_sub.user_limit.to_i}, You choose #{@current_organization.active_users.count} ", status: :unprocessable_entity 
        format.json { render json: "Max allowed user: #{current_sub.user_limit.to_i}. please choose users as per limit. We have disabled all users except super admin.", status: :unprocessable_entity }
      else
        format.json { render json: "success", status: :unprocessable_entity }
      end          
    end
    # render :text => "success"
  end

  def block_unblock_user
    user = @current_organization.users.find_by_id(params[:user_id])
    user.update_attributes(is_blocked: params[:type] == "block" ? true : false)
    render :json => {user_id: user.id, type: params[:type]}
  end

  def grant_revoke_admin
    user = @current_organization.users.find_by_id(params[:user_id])
    user.update_attributes(admin_type: params[:type] == "grant" ? 2 : 3)
    render :json => {user_id: user.id, type: params[:type]}
  end
  
  def save_password
    if @user.update_attributes(params[:user])
      sign_in(@user, :bypass => true)
      flash[:bosuccess] = "Password updated successfully."
      redirect_to "/profile"
    else
      respond_to do |format|
        format.html { render :action => "change_password" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  def get_source_list
    render :partial=> "users/source_list"
  end
  
  def get_industry_list
    render :partial=> "users/industry_list"
  end
 def source_list
    respond_to do |format|
      format.html
      format.json { render json: SourcesDatatable.new(view_context) }
    end
  end
  # plugin integration start
  def plugin_integration
    #@title = "InSet CRM | Free CRM Tool |Plugins Integration"
    @description = "At InSet CRM the free crm tool, registered user can integrate our customized Plugins to their account for smooth and faster work."
  end  
  # plugin integration end
  #Add a new plug in
  def add_plug_in
    user_plugin = UserPlugin.new
    user_plugin.user_id = current_user.id
    user_plugin.plugin_id = params[:id]
    user_plugin.save
    redirect_to "/plugin_integration"
  end
 def delete_source
    source = Source.find(params[:id])
    source.destroy
  respond_to do |format|
      flash[:notice]="Source has been successfully deleted."
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
 end 
  
  def industry_list
    respond_to do |format|
      format.html
      format.json { render json: IndustriesDatatable.new(view_context) }
    end
  end
  def delete_industry
    industry = Industry.find(params[:id])
    industry.destroy
    respond_to do |format|
      flash[:notice]="Industry has been successfully deleted."
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def save_profile_info
    @user = User.find params[:name]
    if params[:pk] == '1'
      @user.update_attributes({first_name: params[:value]})
    elsif params[:pk] == '2'
      @user.update_attributes({last_name: params[:value]})
    elsif params[:pk] == '3'
      if @user.phone.present?
          @user.phone.update_attributes({phone_no: params[:value]})
      else
        Phone.create(organization_id: @current_organization.id,phone_no: params[:value], phoneble_type: "User", phoneble_id: @user.id)
      end
    elsif params[:pk] == '4'
      @user.update_attributes({time_zone: params[:value]})
    elsif params[:pk] == '5'
      @user.update_attributes({email: params[:value]})
    elsif params[:pk] == '6'
      @user.organization.update_attributes({name: params[:value]})
    elsif params[:pk] == '7'
      @user.organization.update_attributes({website: params[:value]})
    elsif params[:pk] == '8'
      @user.organization.update_attributes({size_id: params[:value]})
    elsif params[:pk] == '9'
      @user.update_attributes({user_designation_id: params[:value]})
    elsif params[:pk] == '10'
      @current_user.user_hourly_billables.update_all(is_active: false)
      user_hrly_billable = @current_user.user_hourly_billables.new({organization: @current_organization, amount: params[:value]})
      if user_hrly_billable.save
        @user.update_attributes({user_hourly_billable_id: user_hrly_billable.id})
      end
    end
    # expire_fragment("user_menu_#{@user .id}") #if fragment_exist?("user_menu_#{@user .id}")
    render :text => @user.full_name
  end
  
  def resend_invitation
    User.find(params[:user_id]).invite!
    flash[:notice]="Invitation email has been re-sent to the user."
    redirect_to request.referrer
  end
  
  def profile
    @all_users = User.where("organization_id=?",@current_organization.id)
    #@all_users =current_user.organization.users
    #@title = "InSet CRM | Free CRM Tool | User Profile"
    @description = "InSet CRM the free crm tool registered users can manage and update their profile with required information."
   begin
    if params[:id].present?
      en = params[:id].gsub("-",'/').gsub(" ","+")
      begin
        user_id = AESCrypt.decrypt(en, "userid")
        @user = @all_users.find_by_id(user_id)
      rescue
        flash[:danger] = "Invalid user encryption ID"
        redirect_to root_path and return
      end
    else
      @user = @current_user
    end
   unless @current_user.is_siteadmin?
      @allowed_user =  !params[:id].present? ? true : (( params[:id].to_i == current_user.id ) || (current_user.is_admin? || current_user.is_super_admin?) ? true : false)
    end

     
   rescue ActiveRecord::RecordNotFound
      flash[:alert]="No such user exist!"
      redirect_to profile_path
    end
  
  
  end
  
  def enable_usr
    usr = User.find params[:id]
    usr.update_attribute(:is_active, true)
    flash[:notice]="User has been successfully activated."
    redirect_to request.referrer
  end
  
  def create_admin_user
	# unless Organization.present?
		# rake db:seed
	# end
    org = Organization.first
    # unless is_valid_license_key(params[:user][:token], params[:user][:license_key])
      # flash[:alert]="Invalid License Key!"
      # redirect_to root_path
      # return
    # end
    # org.update_attributes({:name => params[:user][:organization_name], :token => params[:user][:token]})
    user = User.create(:email => params[:user][:email],:password => params[:user][:password],:organization_id => org.id, :admin_type => 1,:confirmation_token=>nil, :confirmed_at=>Time.now)
    # org.process_license(params[:user][:license_key],user)
    # org.update_column :maintenance_period_ends_on, user.organization.reload.licensekey_info[2].to_date
    redirect_to root_path, notice: "Successfully created admin user."
  end

  def edit_user
   @user = User.find(params[:user_id])
    render partial: "edit_user"
  end

  def assign_deal_to_user
    @user = User.find(params[:user_id])
    render partial: "dual_list"
  end

  def remove_lead
    @user = User.find(params[:user_id])
    render partial: "remove_lead"
  end
  
  def load_header_count_user
      if params[:id].present?
        en = params[:id].gsub("-",'/').gsub(" ","+")
        user_id = AESCrypt.decrypt(en, "userid")
        params[:id] = user_id
      end
      unless @current_user.is_siteadmin?
        @tasks=nil
        @tasks=Task.task_list(@user, "today",nil,nil,nil,nil) if @user.present?
        @tasks = @tasks.limit(10) if @tasks.present?
        @task_type="today"      
        count_condition=get_deal_status_count_user([1,2,3,4,5,6,7,8],@user)
        @new_ds=@current_organization.deal_statuses.where("name=?","New").first
        @qualified_ds=@current_organization.deal_statuses.where("name=?","Qualified").first
        @new_deals = @new_ds.present? ? @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.filter_deal_status(@new_ds.id,@current_organization.id).id).count : 0
        @qualified_deals = @ualified_ds.present? ? @current_organization.deals.where(:is_active=>true,:deal_status_id=>@current_organization.filter_deal_status(@qualified_ds.id,@current_organization.id).id).count : 0

        unless params[:id].present?
          if @current_user.is_admin?
            @open_leads = @current_organization.deals.where("is_won IS NULL and is_active=?",true).count
            @closed_leads = @current_organization.deals.where("is_won IS NOT NULL").count
            @task_count = @current_organization.tasks.where("is_completed=?",false).count
          else
            # @open_leads = @current_organization.deals.where("(initiated_by =? OR assigned_to =?) AND is_won IS NULL", @current_user.id, @current_user.id).count
            # @closed_leads = @current_organization.deals.where("(initiated_by =? OR assigned_to =?) AND is_won IS NOT NULL", @current_user.id, @current_user.id).count
            # @task_count = @current_organization.tasks.where("(created_by=? OR assigned_to=?) AND is_completed=?", @current_user.id, @current_user.id,false).count
            #------------
            get_durations('current_week')
            
            @this_week_jobs = @current_user.project_jobs.where("due_date between ? and ? and status  in ('New','In Progress')",@start_date,@end_date).count
            @today_jobs = @current_user.project_jobs.where("due_date = ? and status  in ('New','In Progress')",Date.today).count
            @overdue_jobs = @current_user.project_jobs.where("due_date < ? and status  in ('New','In Progress') ",Date.today).count
            @completed_jobs = @current_user.project_jobs.where("(due_date  between ? and ? ) and status  in ('Resolved','Closed') ",@start_date,@end_date).count
          end
        else
          user=User.find_by_id params[:id]
          @open_leads = user.deals.where("is_won IS NULL and is_active=?",true).count
          @closed_leads = user.deals.where("is_won IS NOT NULL").count
          @task_count = user.all_tasks_assigned.where("is_completed=?",false).count
        end

        #@new_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) ", [1]).count
        @working_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?) AND is_current=? ", [1,2,3,4,5,6], true).count
        #@qualified_deals = Deal.includes(:deal_status).select("deals.id, deal_statuses.original_id").where(count_condition).where("deal_statuses.original_id IN (?)", [2]).count
        #@deals = @user.all_assigned_or_created_deals.limit(10)
        
          # if badge_today_user(@user) > 0
          #   @task_count = badge_today_user(@user)
          #   @task_text="Today's tasks"
          #   @task_url = "/tasks?type=today"
          # elsif badge_overdue_user(@user) > 0
          #   @task_count = badge_overdue_user(@user)
          #   @task_text="Overdue tasks"
          #   @task_url = "/tasks?type=overdue"
          # elsif badge_upcoming_user(@user) > 0
          #   @task_count = badge_upcoming_user(@user)
          #   @task_text="Upcoming tasks"
          #   @task_url = "/tasks?type=upcoming"
          # else
          #   @task_count = badge_all_user(@user)
          #   @task_text="Tasks"
          #   @task_url = "/tasks"
          # end

          @allowed_user =  !params[:id].present? ? true : (( params[:id].to_i == current_user.id ) || (current_user.is_admin? || current_user.is_super_admin?) ? true : false)
          if(@current_user.is_super_admin? || @current_user.is_admin?)
            render partial: "user_load_header_count_section", :content_type => 'text/html'
          else
            render partial: "user_load_header_count_jobs", :content_type => 'text/html'
          end
     end
  end
def save_tmp_img
    text="fail"
    #if remotipart_submitted?
  puts ">>>>>>>>>>>..this is before checking user"
      @user=User.where("id=?", params[:user_id]).first
    p @user
    puts ">>>>>>>>>>>..getting user"
      if @user.present?
     begin
     puts ">>>>>>>>>>>..if useris present"
     @tempImage= TempImage.create!(:user_id=> @user.id, :avatar=> params[:user][:profile_image])
     text="success" if !@tempImage.nil?
     rescue => e
      p e.message
    p e.backtrace
      text="fail" 
     end
      end
    #end
    if text=="success"
      render partial: "crop"
    else
      render :text => text
    end
  end
  
  
  def update_profile_image
  @user=User.where("id=?",params[:user_id]).first 
  
  respond_to do |format|
    @tmpimage=TempImage.find params[:id]
    @tmpimage.crop_x =params["temp_image"]["avatar"]["crop_x"]
    @tmpimage.crop_y =params["temp_image"]["avatar"]["crop_y"]
    @tmpimage.crop_w =params["temp_image"]["avatar"]["crop_w"]
    @tmpimage.crop_h =params["temp_image"]["avatar"]["crop_h"]
    @tmpimage.crop
    
    unless @user.image.present?
      @user.image = Image.create!( :organization => @current_organization, :imagable => @user )
    end
    if(@user.image.update_attribute :image,@tmpimage.avatar)
        expire_fragment("user_menu_#{@user.id}")
        @tmpimage.destroy
        format.json{render json: {imagesmall: @user.image.image.url(:thumb), imagesmall: @user.image.image.url(:small) ,imageicon: @user.image.image.url(:icon)}}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  def save_daily_updates
    @deal = Deal.find_by_id(params[:hdn_deal_id])
    if @deal.present? && @deal.daily_update.present?
      @deal.daily_update.update_attributes(:deal_id=>params[:hdn_deal_id], :time_zone=>params[:daily_updates][:time_zone], :user_ids => params[:hdn_user_ids], :frequency=>params[:hdn_frequency], :alert_time => params[:daily_updates]['alert_time(4i)'] + ":" + params[:daily_updates]['alert_time(5i)'])
    else
      DailyUpdate.create(:deal_id=>params[:hdn_deal_id], :time_zone=>params[:daily_updates][:time_zone], :user_ids => params[:hdn_user_ids], :frequency=>params[:hdn_frequency], :alert_time => params[:daily_updates]['alert_time(4i)'] + ":" + params[:daily_updates]['alert_time(5i)'])
    end
    flash[:notice] = "Daily update saved successfully."
    if request.referrer.include?("manage_daily_update")
      redirect_to "/manage_daily_updates"
    else
      redirect_to "/daily_updates"
    end
  end

  def manage_daily_updates
    @daily_updates = @current_organization.deals.map {|d| d.daily_update}.compact
  end

  def edit_daily_update
    @daily_update = DailyUpdate.find_by_id params[:id]
    @deal = @daily_update.deal
    users = []
    users << @deal.assigned_user
    @deal.tasks.map{|t|t.user}.each do |user|
      users << user
    end
    @users = users.uniq
    render :partial => "edit_daily_update"
  end

  def delete_daily_update
    @daily_update = DailyUpdate.find_by_id params[:id]
    if @daily_update.destroy
      flash[:notice] = "Daily update deleted successfully."
    else
      flash[:error] = "Something went wrong."
    end
    redirect_to manage_daily_updates_path
  end

  def resend_invite
    begin
      user = User.find_by_id params[:user_id]
      user.invite!(@user)
      render :json => {user_email: user.email, status: "success"}
    rescue
      render :json => {status: "error"}
    end
  end

  def delete_invitation_not_accepted_user
    begin
      user = User.find_by_id params[:user_id]
      user.destroy
      render :json => {status: "success"}
    rescue
      render :json => {status: "error"}
    end
  end

  def get_users
    unless params[:org_id].present?
      @organization = @current_organization
    else
      @organization = Organization.where("id=?",params[:org_id]).first
    end
    case params[:type]
    when 'admin'
      @users = @organization.users.where("admin_type=?",2)
    when 'user'
      @users = @organization.users.where("admin_type=?",3)
    when 'blocked'
      @users = @organization.users.where("is_blocked=?",true)
    when 'invite_sent'
      @users = @organization.users.where("invitation_token IS NOT NULL AND invitation_accepted_at IS NULL")
    when 'disabled'
      @users = @organization.users.where("is_disabled=?",true)
    else
      @users = @organization.users
    end    
    render :partial => "get_users"
  end

  def enable_disable_user
    user = @current_organization.users.find_by_id(params[:user_id])
    user.update_attributes(:is_disabled => user.is_disabled ? false : true, :is_active => user.is_disabled ? true : false)
    user.update_attributes(:is_blocked => false) if user.is_blocked == true
    @users = @current_organization.users
    render :partial => "get_users"
  end

  def get_users_dual_list
    @inactive_users = @current_organization.users.by_inactive.where("admin_type !=?", 1)
    @active_users = @current_organization.users.by_active.where("admin_type !=?", 1)
    render partial: "users_dual_list"
  end
  def download_back_up_data
    Spreadsheet.client_encoding = 'UTF-8'
    spreadsheet_file = Spreadsheet::Workbook.new
    deals_tab = spreadsheet_file.create_worksheet :name => 'Leads'
    contacts_tab = spreadsheet_file.create_worksheet :name => 'Contacts'
    tasks_tab = spreadsheet_file.create_worksheet :name => 'Tasks'
    users_tab = spreadsheet_file.create_worksheet :name => 'Users'
    organizations_tab = spreadsheet_file.create_worksheet :name => 'Organizations'
    projects_tab = spreadsheet_file.create_worksheet :name => 'Projects'
    project_tasks_tab = spreadsheet_file.create_worksheet :name => 'Project Tasks'
    invoices_tab = spreadsheet_file.create_worksheet :name => 'Invoices'

    deals_tab.row(0).push "Name", "Opportunity", "Contact", "Phone No.", "Location", "Amount", "Next Action", "Stage", "Type"
    contacts_tab.row(0).push "Contact Name", "Email", "Company", "Country", "Phone No.", "Website", "Opportunity"
    tasks_tab.row(0).push "Task Details", "Lead Associated", "Opportunity", "Outcome / Next Action", "Task Type"
    users_tab.row(0).push "Name", "Email", "Role", "Lead Associated", "Task Associated", "Total Activities", "Added On"
    organizations_tab.row(0).push "Org. Name", "#People Involved", "#Leads", "#Contacts", "Org. Owner", "#Tasks"
    projects_tab.row(0).push "Project Name", "Opportunity Associated", "Lead Associated", "Description", "#Users", "#Jobs", "Status", "Last Activity"
    project_tasks_tab.row(0).push "Job Title / Name", "Opportunity", "Lead Name", "Assigned to", "Priority", "Updated", "Status", "Due Date"
    invoices_tab.row(0).push "Invoice#", "Bill To", "Description", "Amount($)", "Due Date", "Status", "Generated Date"
    
    deals = @current_organization.deals.by_is_active.order("updated_at desc")
    tasks = @current_organization.tasks.order("updated_at desc")
    contacts = @current_organization.individual_contacts.by_not_archived.order("updated_at desc")
    users = @current_organization.users.order("updated_at desc")
    organizations = @current_organization.company_contacts.order("updated_at desc")
    projects = @current_organization.projects.order("updated_at desc")
    projects_tasks = @current_organization.project_jobs.order("updated_at desc")
    invoices = @current_organization.invoices.order("updated_at desc")
    if deals.present?
      deals.each_with_index do |deal, i|
        deals_tab.row(i+1).push deal.contact_name.present? ? deal.contact_name : ""
        deals_tab.row(i+1).push deal.title
        deals_tab.row(i+1).push deal.contact_email.present? ? deal.contact_email : ""
        deals_tab.row(i+1).push deal.deals_contacts.present? ? (deal.deals_contacts.first.contactable.present? && deal.deals_contacts.first.contactable.phones.present? ? deal.deals_contacts.first.contactable.phones.first.phone_no : "") : ""
        deals_tab.row(i+1).push deal.country_id.present? && deal.current_country.present? ? deal.current_country.name : ''
        deals_tab.row(i+1).push deal.amount.present? ? deal.amount.to_i : ''
        deals_tab.row(i+1).push deal.last_task.present? ? deal.last_task.name  : "No-Action"
        deals_tab.row(i+1).push deal.deal_status_name
        deals_tab.row(i+1).push deal.priority_type.present? ? deal.priority_type.name.titlecase : "NA"
      end
    end
    if tasks.present?
      tasks.each_with_index do |task, i|
        tasks_tab.row(i+1).push task.get_title_hover
        tasks_tab.row(i+1).push (task.deal.present? && task.deal.contact_name.present? ? task.deal.contact_name : "") + "(#{task.deal.present? && task.deal.contact_email.present? ? task.deal.contact_email : ''})"
        
        tasks_tab.row(i+1).push task.get_opportunity_title
        tasks_tab.row(i+1).push task.task_note.present? ? task.task_note : ""
        tasks_tab.row(i+1).push task.task_type.present? ? task.task_type.name : "None"
      end
    end
    if contacts.present?
      contacts.each_with_index do |con, i|
        contacts_tab.row(i+1).push con.full_name.present? ? con.full_name : "NA"
        contacts_tab.row(i+1).push con.email.present? ? con.email : "NA"
        contacts_tab.row(i+1).push con.company_contact.present? ? con.company_contact.name : "NA"
        contacts_tab.row(i+1).push con.country.present? ? con.country.name : ""
        ph = con.phones.by_phone_type "work"
        contacts_tab.row(i+1).push ph.present? && ph.first.phone_no.present? ? ph.first.phone_no : ""
        contacts_tab.row(i+1).push con.website.present? ? con.website : ""
        contacts_tab.row(i+1).push con.deals_contacts.present? ? con.deals_contacts.last.deal.title : ''
      end
    end
    if users.present?
      users.each_with_index do |user, i|
        users_tab.row(i+1).push user.full_name.present? ? user.full_name : user.email.split("@")[0] 
        users_tab.row(i+1).push user.email
        if user.is_super_admin?
          role = "Super Admin"
        elsif user.is_admin?
          role = "Admin"
        else
          role = "User"
        end
        users_tab.row(i+1).push role
        users_tab.row(i+1).push user.all_assigned_deal.count
        users_tab.row(i+1).push user.all_tasks_assigned.count
        users_tab.row(i+1).push user.activities.count
        users_tab.row(i+1).push user.created_at.strftime("%b %d, %Y")
      end
    end

    if organizations.present?
      organizations.each_with_index do |company, i|
        organizations_tab.row(i+1).push company.name
        organizations_tab.row(i+1).push company.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten.map{|d|d.tasks}.compact.flatten.map{|t|t.user}.compact.uniq.count
        organizations_tab.row(i+1).push company.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten.count
        organizations_tab.row(i+1).push company.individual_contacts.count
        organizations_tab.row(i+1).push company.individual_contacts.present? ? company.individual_contacts.first.name : ""
        organizations_tab.row(i+1).push company.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten.map{|d|d.tasks}.compact.flatten.count
      end
    end

    if projects.present?
      projects.each_with_index do |project, i|
        projects_tab.row(i+1).push project.name
        projects_tab.row(i+1).push project.deal.present? && project.deal.is_active ? project.deal.title : ""
        projects_tab.row(i+1).push project.individual_contact.present? ? project.individual_contact.name: ""
        projects_tab.row(i+1).push project.description.present? ? project.description : "NA"
        projects_tab.row(i+1).push project.project_users.map{|p|p.user}.compact.count
        projects_tab.row(i+1).push project.project_jobs.count
        projects_tab.row(i+1).push project.status
        projects_tab.row(i+1).push project.updated_at.strftime("%b %d, %Y @ %H:%M %P")
      end
    end

    if projects.present?
      projects_tasks.each_with_index do |project_job, i|
        project_tasks_tab.row(i+1).push project_job.name
        project_tasks_tab.row(i+1).push project_job.project.present? && project_job.project.deal.present? ? project_job.project.deal.title : "NA"
        project_tasks_tab.row(i+1).push project_job.project.present? && project_job.project.deal.present? ? (project_job.project.deal.deals_contacts.first.contactable.full_name.present? ? project_job.project.deal.deals_contacts.first.contactable.full_name : project_job.project.deal.deals_contacts.first.contactable.email) : "NA"
        project_tasks_tab.row(i+1).push project_job.user_responsible.present? ? (project_job.user_responsible.full_name.present? ? project_job.user_responsible.full_name : project_job.user_responsible.email) : ""
        project_tasks_tab.row(i+1).push project_job.priority
        project_tasks_tab.row(i+1).push project_job.updated_at.strftime("%b %d, %Y @ %H:%M %P")
        project_tasks_tab.row(i+1).push project_job.status
        project_tasks_tab.row(i+1).push project_job.due_date.present? ? project_job.due_date.strftime("%b %d,%a") : "NA"
      end
    end

    if invoices.present?
      invoices.each_with_index do |invoice, i|
        if invoice.invoice_items.present? && (items=invoice.invoice_items.where("description is NOT NULL and description != ''").map(&:description)).present?
          desc_index = 1
          inv_desc = ""
          items.each do |item|
            inv_desc = inv_desc + "#{desc_index}. #{item}\n"
            desc_index+=1
          end
        end
        invoices_tab.row(i+1).push invoice.invoice_no.present? ? invoice.invoice_no : "NA"
        ind_cont = @current_organization.individual_contacts.where("id=?",invoice.contact_id).first
        invoices_tab.row(i+1).push ind_cont.name.present? ? ind_cont.name : ind_cont.email
        invoices_tab.row(i+1).push inv_desc
        invoices_tab.row(i+1).push invoice.total_amount
        invoices_tab.row(i+1).push invoice.due_date.present? ? invoice.due_date.strftime("%m/%d/%Y") : "NA"
        invoices_tab.row(i+1).push invoice.status.present? ? (invoice.status == "Send" ? "Sent" : invoice.status) : "NA"
        invoices_tab.row(i+1).push invoice.created_at.strftime("%m/%d/%Y") 
      end
    end
    

    
    spreadsheet = StringIO.new
    spreadsheet_file.write spreadsheet
    # send_data spreadsheet.string, :filename => "WakeUpSales_Back_Up_Data.xls", :type =>  "application/vnd.ms-excel"
    
    Notification.send_back_up_data_to_super_admin(@current_user, spreadsheet.string, @current_organization.name).deliver

    render text:"success"
  end

  def update_license_key
    org = Organization.first
    unless is_valid_user_license_key(org.token, params[:license_key])
      render text: "fail"
      return
    end
    org.current_license_key.update_column :is_active, false
    org.process_license(params[:license_key],@current_user,"u")
    render text: params[:license_key]
    # redirect_to root_path, notice: "Successfully upgraded user limit."
  end
  

  ######## Getting started forms
  def gs_save_name  
    @current_user.first_name = params[:user][:first_name]
    @current_user.last_name = params[:user][:last_name]
    @current_user.save
    render :text=>"success"
  end
  def gs_save_phone_no

    if @current_user.phone.present?
      @current_user.phone.update_attributes({phone_no:  params[:user][:phone_no],extension: params[:user][:area_code]})
    else
      Phone.create(organization_id: @current_organization.id,phone_no:  params[:user][:phone_no], extension: params[:user][:area_code],phoneble_type: "User", phoneble_id: @current_user.id)
    end
    render :text=>"success"
  end
  def gs_save_address
    if @current_user.address.present?
      @current_user.address.update_attributes(params[:user][:address_attributes])
    else
      @current_user.address.create(params[:user][:address_attributes])
    end
    render :text=>"success"
  end
  def gs_save_org_size
    @current_user.organization.size_id = params[:organization][:size_id]
    @current_user.organization.save
    render :text=>"success"
  end
  def gs_save_time_zone
    puts "saving time_zone...................."
    @current_user.organization.update_attributes({:time_zone=>params[:organization][:time_zone]})
    @current_user.organization.update_attributes({:time_zone=>params[:organization][:time_zone]})
    render :text=>"success"
  end
  def gs_save_org_tmp_image
    # text="fail"
    # begin
    #   @tempImage= TempImage.create!(:user_id=> @current_user.id, :avatar=> params[:organization][:image])
    #   text="success" if !@tempImage.nil?
    # rescue => e
    #   p e.message
    #   p e.backtrace
    #   text="fail" 
    # end
    
    # #end
    # if text=="success"
    #   render partial: "crop"
    # else
    #   render :text => text
    # end
  end
  def gs_save_org_image
    if @current_user.organization.image.present? 
      @current_user.organization.image.update_attributes(params[:organization][:image_attributes])
    else
      @current_user.organization.image.create(params[:organization][:image_attributes])
    end
    
    render :text=>@current_user.organization.image.image.url(:original)
  end
  def gs_save_industries
    organization_industries = @current_organization.organization_industries
    if(params[:organization][:organization_industries_attributes].present?)
      params[:organization][:organization_industries_attributes].each do |k,v|
        if v[:id].present? && v[:company_industry_id].present?
          # unless project_users.where(user_id: v[:user_id].to_i, id: v[:id].to_i).present?
          #   @project.project_users.build(:user_id => v[:user_id].to_i, :id => v[:id].to_i)
          # end
        else
          if v[:id].present? && !v[:company_industry_id].present?
            pindustries = organization_industries.where(id: v[:id].to_i).delete_all
          elsif !v[:id].present? && v[:company_industry_id].present?
            @current_organization.organization_industries.build(:company_industry_id => v[:company_industry_id].to_i)
          end
        end
      end
    end
    @current_organization.save
    render :text=>"success"
  end
  def gs_save_currency
    @current_user.organization.default_currency = params[:organization][:default_currency]
    @current_user.organization.save
    render :text=>"success"
  end
  def gs_save_sales_stages
    params[:organization][:deal_statuses_attributes].each do |k,ds|      
      if(ds[:name].downcase == "won" || ds[:name].downcase == "lost")
        next
      elsif ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        @current_user.organization.deal_statuses.where(:id =>ds[:id] ).first.update_attributes(:name=>ds[:name])
      elsif !ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        #ds1 = ds.delete(:_destroy)
        if !(existing_ds = @current_user.organization.deal_statuses.where("name = ?",ds[:name] ).first).present?
          @current_user.organization.deal_statuses.create(name: ds[:name]) if !ds[:id].present?
        end
      elsif ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] == "1" 
        (ds = @current_user.organization.deal_statuses.where(:id =>ds[:id] ).first).destroy if ds.present?
      end

    end
    render :text=>"success"
  end
  def gs_save_task_types
    params[:organization][:task_types_attributes].each do |k,ds|      
      if(ds[:name].downcase == "appointment")
        next
      elsif ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        @current_user.organization.task_types.where(:id =>ds[:id] ).first.update_attributes(:name=>ds[:name])
      elsif !ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        #ds1 = ds.delete(:_destroy)
        if !(existing_ds = @current_user.organization.task_types.where("name = ?",ds[:name] ).first).present?
          @current_user.organization.task_types.create(name: ds[:name]) if !ds[:id].present?
        end
      elsif ds["_destroy"].present? && ds["_destroy"] == "1" && ds[:id].present?
        @current_user.organization.task_types.where(:id =>ds[:id]).first.destroy
      end
    end
    render :text=>"success"
  end
  def gs_save_task_outcomes
    params[:organization][:task_outcomes_attributes].each do |k,ds|      
      if ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        @current_user.organization.task_outcomes.where(:id =>ds[:id] ).first.update_attributes({name: ds[:name],task_out_type: ds[:task_out_type],task_duration: ds[:task_duration]})
      elsif !ds[:id].present? && ds[:_destroy].present? && ds[:_destroy] != "1"
        #ds1 = ds.delete(:_destroy)
        if !(existing_ds = @current_user.organization.task_outcomes.where("name = ?",ds[:name] ).first).present?
          @current_user.organization.task_outcomes.create(name: ds[:name],task_out_type: ds[:task_out_type],task_duration: ds[:task_duration]) if !ds[:id].present?
        end
      elsif ds[:_destroy].present? && ds[:_destroy] == "1" && ds[:id].present?
        @current_user.organization.task_outcomes.where(:id =>ds[:id]  ).first.delete
      end
    end
    render :text=>"success"
  end
  def gs_save_lost_reasons
    params[:organization][:lost_reasons_attributes].each do |k,ds|      
      if ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        @current_user.organization.lost_reasons.where(:id =>ds[:id] ).first.update_attributes(:reason=>ds[:reason])
      elsif !ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        #ds1 = ds.delete(:_destroy)
        if !(existing_ds = @current_user.organization.lost_reasons.where("reason = ?",ds[:reason] ).first).present?
          @current_user.organization.lost_reasons.create(reason: ds[:reason]) if !ds[:id].present?
        end
      elsif ds["_destroy"].present? && ds["_destroy"] == "1" && ds[:id].present?
        @current_user.organization.lost_reasons.where(:id =>ds[:id]).first.destroy
      end
    end
    render :text=>"success"
  end
  def gs_save_project_stages
    params[:organization][:project_stages_attributes].each do |k,ds|      
      if ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        @current_user.organization.project_stages.where(:id =>ds[:id] ).first.update_attributes(:name=>ds[:name])
      elsif !ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        if !(existing_ds = @current_user.organization.project_stages.where("name = ?",ds[:name] ).first).present?
          @current_user.organization.project_stages.create(name: ds[:name],is_active: true) if !ds[:id].present?
        end
      elsif ds["_destroy"].present? && ds["_destroy"] == "1" && ds[:id].present?
        @current_user.organization.project_stages.where(:id =>ds[:id]).first.destroy
      end
    end
    render :text=>"success"
  end
  #Add user roles
  def gs_save_user_roles
    params[:organization][:roles_attributes].each do |k,ds|      
      if ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        @current_organization.roles.where(:id =>ds[:id] ).first.update_attributes(:name=>ds[:name])
      elsif !ds[:id].present? && ds["_destroy"].present? && ds["_destroy"] != "1"
        if !(existing_ds = @current_organization.roles.where("name = ?",ds[:name] ).first).present?
          @current_organization.roles.create(name: ds[:name]) if !ds[:id].present?
        end
      elsif ds["_destroy"].present? && ds["_destroy"] == "1" && ds[:id].present?
        @current_organization.roles.where(:id =>ds[:id]).first.destroy
      end
    end
    render :text=>"success"
  end
  #Get user roles
  def get_user_roles
    @roles=@current_organization.roles.select("id, name") if @current_organization.present?
    render :partial => "roles_div"
  end
  def configure_user_smtp
    begin
      if params[:smtp_configuration][:smtp_host] == "smtp.gmail.com"
        render text:"choosed_gmail"
      else
        Net::SMTP.start(params[:smtp_configuration][:smtp_host], params[:smtp_configuration][:port]) do |smtp|
        end
        unless (user_smtp_config = @current_user.smtp_configuration).present?
          smtp_configuration = SmtpConfiguration.create(params[:smtp_configuration])
          smtp_configuration.update_attributes({:organization_id => @current_organization.id, :user_id => @current_user.id})
        else
          user_smtp_config.update_attributes(params[:smtp_configuration])
        end
        @current_user.update_column :smtp_config, "other"
        render text:"success"
      end
    rescue Exception => e
      render text:"fail"
    end
  end

  def setup_email_with_inset
    @current_user.update_column :smtp_config, "inset"
    flash[:notice] = "Email address setup successfully with Wakeupsales."
    redirect_to request.referrer
  end
  
  # def get_all_calendar_data
  #   if request.xhr?
  #     events = []
  #     start_date,end_date="",""
  #     start_date =Time.zone.at(params[:start].to_i).strftime("%Y/%m/%d") if params[:start].present?
  #     end_date =Time.zone.at(params[:end].to_i).strftime("%Y/%m/%d") if params[:end].present?
     
  #     if (params[:deal_type] != "" ||  params[:asg_to] != "" || params[:task_type] != "")
  #       @tasks = @tasks.active_multi_filter(params)
  #     end
  #     #@tasks=@tasks.where("is_completed=? AND DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') BETWEEN ? AND ?", false, start_date, end_date )
  #     # if params[:filter_type].present? && params[:filter_type] == "all"
  #       @tasks=@tasks.where("DATE_FORMAT(DATE_ADD(due_date, INTERVAL ? second), '%Y/%m/%d') BETWEEN ? AND ?", Time.zone.now.utc_offset, start_date, end_date)
  #     # else
  #     #     @tasks=@tasks.where("DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') BETWEEN ? AND ? and (DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') = ? or DATE_FORMAT(DATE_ADD(due_date, INTERVAL #{Time.zone.now.utc_offset} second), '%Y/%m/%d') > ?)",start_date, end_date, Time.zone.now.strftime("%Y/%m/%d"),Time.zone.now.strftime("%Y/%m/%d") )
  #     # end
  #     @tasks.each do |task|
  #       deal = task.taskable
  #       if task && deal
  #         task.due_date= task.created_at unless task.due_date.present?
  #         if  task.user && task.user.image && task.user.image.present?
  #          imgurl = task.user.image.image(:icon)
  #         else
  #          imgurl = "/assets/no_user.png"
  #         end
  #         deal_status_name = ""
  #         class_name = deal.class.name
  #         if class_name == "Deal"
  #           class_name = "Lead"
  #           deal_status_name = deal.deal_status_name
  #         elsif class_name == "IndividualContact"
  #           class_name = "Contact"
  #         else
  #           class_name = "Organization"
  #         end
  #         status = task.status.present? ? task.status : ""
            
  #         events << {:linked_to => class_name, :class_name => class_name, :id => task.id, :img=>imgurl, :is_complete=> task.is_completed, :tasktype=> task.task_type.present? ? task.task_type.name : "None" , :assign_to=> "#{(task.user.present? ? (task.user.full_name.present? ? task.user.full_name : task.user.email) : 'NA')}", :url=> "javascript:void(0)", :title => task.title ,:lead_info => deal.title, :className=>"test",  :color=> "#ddd", :description => "At - #{task.due_date.strftime('%I:%M %p')}\nTask - "+task.title+"\n Deal - " + deal.title+"\nAssigned To - "+(task.user ? task.user.full_name : ""), :start => "#{task.due_date.iso8601}", :end => "#{task.due_date.iso8601}", :allDay => false, :start_date => task.due_date.strftime('%d %b, %Y'), :start_time => task.due_date.strftime('%I:%M%p'), :lead_url => "http://#{request.host_with_port}/leads/#{deal.to_param}", :details => task.details, :deal_status => deal_status_name, :status => status}
  #       end
  #     end
  #   end
  #   # http://#{request.host_with_port}/leads/#{deal.to_param}
  #   # ,   :color=> TaskType::TASK_COLORS[task.task_type.present? ? task.task_type.name : "None"]
  #   respond_to do |format|
  #     format.json { render json: events}
  #   end
  # end
  private
  def can_invite_user
    if @current_organization.active_users.count >= @current_organization.users_limit
      render :text => "Sorry, User Limit has Exceeded!", status: :unprocessable_entity
      return false
    end
  end
  def assign_license_key
    @current_license = @current_organization.licensekey_info  
  end


end
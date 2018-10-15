require 'securerandom'
require 'rest-client'
class BetaAccountsController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@parkpointsoftware.com.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

 include ApplicationHelper
  skip_before_filter :authenticate_user!, :except => [:approve, :disapprove]
 def create
  user = User.find_by_email params[:beta_account][:email]
  if user.present?
   if request.xhr?
     render :text => "Email id already registered."
   else
     flash[:warning]= "Ooops!!! You are already registered."
   end
  else
    beta_user =  BetaAccount.find_by_email params[:beta_account][:email]
    if beta_user.present?
      if request.xhr?
         render :text => "User has already sent request for beta registration."
      else
        flash[:warning]= "Ooops!!! You have already sent request for beta registration."
      end
    else
      beta_user =  BetaAccount.new params[:beta_account]
      if beta_user.save! && is_valid_user_email(beta_user.email)
        if request.xhr?
          beta_user.update_attributes :is_verified=> true, :is_approved => true
          link = "http://#{request.env['HTTP_HOST']}/bsignup?t=" + beta_user.invitation_token
          Notification.mail_notification_for_signup_to_betauser(beta_user.email,link).deliver
        else
          link = "http://#{request.env['HTTP_HOST']}/bconfirm?token=" + beta_user.invitation_token
          Notification.mail_notification_to_betauser(beta_user.email,link).deliver
        end
      end
      unless request.xhr?
         flash[:notice] = "Thanks for registering for a beta account. Please verify your email account by clicking the verification link sent to your email address."
      else
         render :text => "success"
      end
      
      
    end
  end
  unless request.xhr?
    respond_to do |format|
     format.html { redirect_to request.referer }
    end
  end

 end


 def verify_user
   if BetaAccount.exists?(:invitation_token => params[:token])
     buser = BetaAccount.find_by_invitation_token_and_is_verified params[:token], false
     siteadmin = User.find_by_admin_type 0
     if buser.present?
       buser.update_column :is_verified, true
       flash[:notice] = "Your email account has been verified. You will soon get an instruction to signup."
       if siteadmin.present?
          #Notification.mail_notification_to_siteadmin(siteadmin.email, buser.email).deliver 
      Notification.mail_notification_to_siteadmin("sales@parkpointsoftware.com", buser.email).deliver 
       end
     else   
       flash[:warning] = "Oops!!! your account has already been verified."
     end
   else
     flash[:warning] = "Oops!!! Token is invalid."
   end
   respond_to do |format|
   format.html { redirect_to root_path }
  end
 end


 def approve
   buser = BetaAccount.find params[:buser_id]
   
   if buser.update_column :is_approved, true
      ##Generate new token after admin approval
      unless buser.is_registered
        buser.update_column :invitation_token, (Digest::MD5.hexdigest "#{buser.email}-#{DateTime.now.to_s}")
        link = "http://#{request.env['HTTP_HOST']}/bsignup?t=" + buser.invitation_token
        Notification.mail_notification_for_signup_to_betauser(buser.email,link).deliver 
      end
      approve_all_users_organization(buser.email)
   end
   respond_to do |format|
     flash[:notice] = "User has been approved successfully."
     format.html { redirect_to request.referer }
   end
 end
 
 
 def disapprove
  buser = BetaAccount.find params[:buser_id]
  if buser.update_column :is_approved, false
    disapprove_all_users_organization(buser.email)  
  end
  respond_to do |format|
   flash[:notice] = "User has been disapproved successfully."
   format.html { redirect_to request.referer }
  end
 end

  def save_user_bak
    #,:confirmation_token=>nil, :confirmed_at=>Time.now
    message = ""
    ActiveRecord::Base.transaction do
      org = Organization.where("name =?", params[:user][:organization_name]).first    
      if !org.present?
        new_org = Organization.create(name: params[:user][:organization_name])
      end
      @user = User.where("email =?",params[:user][:email]).first
      if !@user.present?
        if params[:user][:name].present?
          begin
            first_name = params[:user][:name].split(" ")[0]
            last_name = params[:user][:name].split(" ")[1]
          rescue
            first_name = params[:user][:name]
            last_name = nil
          end
        else
          first_name = nil
          last_name = nil
        end

        begin
          if EmailVerifier.check(params[:user][:email])
            @user = User.create(:first_name => first_name, :last_name => last_name, :email => params[:user][:email], :password => params[:user][:password], :admin_type => org.present? ? 3 : 1)
            message = "Thanks for Signing Up. Please check your inbox to confirm your account."
          else
            @user = User.create(:first_name => first_name, :last_name => last_name, :email => params[:user][:email], :password => params[:user][:password], :confirmation_token => nil, :confirmed_at=>Time.now, :admin_type => org.present? ? 3 : 1)
            message = "Please sign in and provide a valid email."
          end
        rescue
          @user = User.create(:first_name => first_name, :last_name => last_name, :email => params[:user][:email], :password => params[:user][:password], :confirmation_token => nil, :confirmed_at=>Time.now, :admin_type => org.present? ? 3 : 1)
          message = "Please sign in and provide a valid email."
        end
      end
      @user.update_column(:organization_id, org.present? ? org.id : new_org.id)
    end
    # if @user.organization.present?
    #   redirect_to getting_started_path
    # else
    #   redirect_to new_organization_path(:id => @user.id), flash: {notice: "Provide all the required information to continue."}
    # end
    flash[:bosuccess] = message
    redirect_to root_path #, :flash => { :bosuccess => "message" }
  end

  def save_user
    
      
    #,:confirmation_token=>nil, :confirmed_at=>Time.now
    puts " ..........1........................."
    user=User.new(params[:user])
    puts " ..........2........................."
    if params[:user][:nickname].present?
      #if verify_recaptcha
        #begin
        puts " ..........3........................."
          my_logger ||= Logger.new("#{Rails.root}/log/save_user.log")
          message = ""
          # pwd = Devise.friendly_token[0,10]#SecureRandom.hex(5)
          ActiveRecord::Base.transaction do
            puts " ..........4........................."
            org_name = params[:user][:organization_name].strip
            user_email = params[:user][:email].strip
            org = Organization.where("name = ?", org_name).first    
            @user = User.where("email =?", user_email).first
            if org.present?
              puts " ..........5........................."
              render  text:"company already exists"
              # flash[:alert] = "Oops! The company name is already taken. Please try another one or contact the Super-admin to join."
              # redirect_to params[:current_page].present? ? params[:current_page] : new_user_registration_path
            else
                  puts " ..........6........................."
                if !@user.present?
                  puts " ..........7........................."
                  begin
                    puts " ..........8........................."
                    new_org = Organization.create(name: org_name, website: params[:user][:organization_website],size_id: params[:user][:organization_size], :short_name =>params[:user][:nickname])
                    
                    @user = User.create(:email => user_email, :password => params[:user][:password], :admin_type => org.present? ? 3 : 1, :is_active => true)
                    puts ">>>>>>>>>>           26        <<<<<<<<<<<<<<<<<<"
                    puts "create default administrative project"
                    
                    Project.create(:organization_id=>org.present? ? org.id : new_org.id,  :is_accessible=>true, :name=>"Administrative",:short_name=>"Admin",:description=>'All Administrative Tasks',:project_type=>'Administrative',:project_manager_id=>@user.id,:created_by => @user.id)

                    puts " ..........811........................."
                    # Notification.mail_notification_for_password_to_betauser(@user.email,pwd).deliver if is_valid_user_email(@user.email)
                    @user.update_column(:organization_id, org.present? ? org.id : new_org.id)
                    puts " ..........822........................."
                    new_org.deals.update_all(assigned_to: @user.id)
                    puts " ..........833........................."
                    message = "Thanks for Signing Up. Please check your email for the password."
                    puts " ..........844........................."
                    sign_in(@user, :bypass => true)
                    puts " ..........855........................."
                    password = "keysalt"
                    puts " ..........866........................."
                    encrypt_user = AESCrypt.encrypt(@user.email, password)
                    puts " ..........877........................."
                    Notification.send_welcome_notification_signup_user(@user.email, encrypt_user,@user.email_series.first).deliver if is_valid_user_email(@user.email)
                  rescue=>ex
                    puts " ..........9........................."
                    puts ex.message
                  end
                  # begin
                  #   if request.host.include?("insethub.com")
                  #     RestClient.post 'http://blog.insethub.com/auto_subscription_blog.php', {email: @user.email, domain: 'cloud'}
                  #   end
                  # rescue
                  # end
                  begin
                    puts " ..........10........................."
                    if request.host.include?("insethub.com") || request.host.include?("insetcrm.com")
                      result = Geocoder.search(request.remote_ip)
                      Notification.mail_notification_to_support(@user, result).deliver
                    end
                  rescue => e
                    my_logger.info("Error during save new user: "+ "Message -> "+e.message)
                    my_logger.info("Remote IP: "+ request.remote_ip)
                    my_logger.info("request host: "+ request.host)
                    my_logger.info(request.host.include?("insetcrm.com"))
                  end
                  # begin
                  #   if request.host.include?("wakeupsales.com")
                  #     @user.create_fomo(request.remote_ip)
                  #   end
                  # rescue
                  # end
                  # sign_in(@user, :bypass => false)
                  # after_sign_in_path_for(@user)
                  render text:"success"
                  # flash[:notice] = message
                  # redirect_to "/users/sign-in" #, :flash => { :bosuccess => "message" }
                else
                  render  text:"email already exists"
                  # flash[:alert] = "This Email id is already in use. Please try another one."
                  # redirect_to params[:current_page].present? ? params[:current_page] : new_user_registration_path
                end
            
            end
          end
        # rescue
        #     render  text:"error"
        #     # flash[:alert] = "Oops! Something went wrong. Please try again."
        #     # redirect_to params[:current_page].present? ? params[:current_page] : new_user_registration_path
        # end
      # else
      #   flash[:alert] = "Oops! Please tick-off the captcha & try again."
      #   redirect_to params[:current_page].present? ? params[:current_page] : new_user_registration_path
      # end
    else
      begin
        # spam_logger ||= Logger.new("#{Rails.root}/log/spam_logger.log")
        # spam_logger.info("-------- Spam Email create---"+ Time.now.to_s + "-----------")
        result = Geocoder.search(request.remote_ip)
        geo_code = result.first.data if result.present? && result.first.present?
        spam_email = SpamEmail.find_or_create_by_email(params[:user][:email].strip)
        spam_email.nickname = params[:user][:nickname]
        spam_email.organization_name = params[:user][:organization_name]
        if geo_code.present?
          spam_email.region_name = geo_code["region_name"] if geo_code["region_name"].present?
          spam_email.city = geo_code["city"] if geo_code["city"].present?
          spam_email.country_name = geo_code["country_name"] if geo_code["country_name"].present?
          spam_email.latitude = geo_code["latitude"] if geo_code["latitude"].present?
          spam_email.longitude = geo_code["longitude"] if geo_code["longitude"].present?
          spam_email.ip = geo_code["ip"] if geo_code["ip"].present?
          spam_email.time_zone = geo_code["time_zone"] if geo_code["time_zone"].present?
        end
        spam_email.save
        Notification.mail_notification_for_spam_email(spam_email,result).deliver
        message = "Thanks for using Inset CRM. Password was sent to your mailbox."
        flash[:bosuccess] = message
        redirect_to "/users/sign-in"
      rescue
      end
    end
  end


  def new_organization
    @current_user = User.where(:id => params[:id]).first

  end

  def update_organization
    user = User.find_by_id params[:user_id]
    unless user.organization.present?
      org = Organization.where("name =?", params[:user][:organization_name].strip).first        
      unless org.present?
        org = Organization.create(name: params[:user][:organization_name].strip, size_id: params[:user][:organization_size], website: params[:user][:organization_website])
        user.update_column(:organization_id, org.id)
        sign_in user
        # redirect_to getting_started_path
        redirect_to leads_path
      else
        flash[:danger] = "The company already exists. Please try another name OR if you work for that company, request the Super-Admin for an invite."
        redirect_to :back
      end
    else
      flash[:danger] = "An organization already associated."
      redirect_to root_path
    end
    #redirect_to root_path
  end

  def cancel_organization
    if user_signed_in?
      sign_out current_user
    end
    redirect_to root_path
  end
end

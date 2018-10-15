class OmniauthCallbacksController < ApplicationController #Devise::OmniauthCallbacksController
#skip_before_filter :store_location
 skip_before_filter  :authenticate_user!
 def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user,request.remote_ip)
    if @user.persisted?      
      unless @user.invitation_token.present?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        if session[:non_authenticate].nil?
            sign_in_and_redirect @user, :event => :authentication
        else
          redirect_to "/tasks?stask_id=#{session[:task_id]}&suser=#{@user.id}"
        end
      else
        flash[:danger] = "An invitation mail has been sent to your registered email id. Please check your inbox & follow the link :)"
        redirect_to root_path
      end
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def linkedin
    auth = env["omniauth.auth"]
    @user = User.connect_to_linkedin(request.env["omniauth.auth"],current_user,request.remote_ip)
    if @user.persisted?
      unless @user.invitation_token.present?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "LinkedIn"
        sign_in_and_redirect @user, :event => :authentication
      else
        flash[:danger] = "An invitation mail has been sent to your registered email id. Please check your inbox & follow the link :)"
        redirect_to root_path
      end
    else
      session["devise.linkedin_uid"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  # def googleoauth2
  #   fsdfsfsf
  #   success = handle_google_response(request.env['omniauth.auth'], @current_account)
  #   redirect_to business_email_mail_path
  # end
  
  def handle_google_response
    begin
      credentials = data['credentials']
      e_account = EmailAccount.new({
                                       provider: data['provider'],
                                       email: data['info']['email'],
                                       access_token: credentials['token'],
                                       refresh_token: credentials['refresh_token'],
                                       expires: credentials['expires'],
                                       expires_at: credentials['expires_at'],
                                       user_id: @current_user.id,
                                       organization_id: @current_organization.id
                                   })
      e_account.save!
    rescue => ex
      p ex.message
      false
    end
  end


  # def after_sign_in_path_for(resource)
  #   if resource.email_verified?
  #     super resource
  #   else
  #     finish_signup_path(resource)
  #   end
  # end
end
require 'gmail_client'
class EmailsController < ApplicationController
  include GmailClient
  include EmailHelper
  include AuthHelper

  before_filter :set_up_api, except: [:create, :connect,:connect_office, :logout, :setup_email_with_inset]
  
  def mail
    p "getting mail ............ ........................."
        
    begin
      unless request.xhr?
        @labels = @api_client.fetch_labels
        p "getting labels ....................................."
        p @labels
      end

      mail_type = params[:mail_type].present? ? params[:mail_type].to_s.upcase : 'INBOX'
      label_id = params[:label_id].present? ? params[:label_id] : 'INBOX'
      begin
        p "coming to getting emails ....................................."
        
        case params[:provider]
          when 'google'
            p "coming to google ....................................."
        
            search_options = {pageToken: params[:page_token].to_s, maxResults: ENV['EMAILS_PER_PAGE'] || 20}
            raw_data, @next_page_token = (params[:q].present?) ? @api_client.search_emails({q: params[:q]}) : @api_client.fetch_emails_by_label(label_id, search_options)
            @emails = raw_data.map { |data| get_basic_info(data) }
          else
            p "coming to else of google ....................................."
        
            @emails = []
        end      
      rescue Exception => e
        # Bugsnag.notify(e)
        p "coming to exception  ....................................."
        p e.message
        @current_user.email_account.destroy if @current_user.email_account
        redirect_to email_connect_path
      end
      
      if request.xhr?
        case mail_type
          when 'SENT'
            render partial: 'sent', status: :ok
          when 'DRAFT'
            render partial: 'drafts', status: :ok
          when 'TRASH'
            render partial: 'trash', status: :ok
          when 'SPAM'
            render partial: 'trash', status: :ok
          else
            render partial: 'inbox', status: :ok
        end
      end
    rescue => ex
      p ex.backtrace("\n")
    end
  end
  def office365
    p params

  token = get_token_from_code params[:code]
  render text: "TOKEN: #{token.token}"
 
  end
	def index
		
	end
	def connect
		account = @current_user.email_account
    redirect_to email_mail_path(account.provider) if account.present?
	end

	def create
		success = false
	    if params[:provider] == 'google'
	      success = handle_google_response(request.env['omniauth.auth'], @current_user)
        @current_user.update_attributes({:smtp_config => "google", :email_setup_at => Time.now}) if @current_user.smtp_config.blank?
        Notification.send_user_verified_mail(request.env['omniauth.auth']['info']['email']).deliver
	    end
	    if success
	      redirect_to "/emails"
	    else
	      redirect_to "/emails/connect", alert: 'An error eccoured during processing your request. Please try again.'
	    end
	end

	def handle_google_response(data, user)
	    begin
	      credentials = data['credentials']
	      e_account = EmailAccount.new({
	                                       provider: data['provider'],
	                                       email: data['info']['email'],
	                                       access_token: credentials['token'],
	                                       refresh_token: credentials['refresh_token'],
	                                       expires: credentials['expires'],
	                                       expires_at: credentials['expires_at'],
                                         organization_id: user.organization_id
	                                   })
	      e_account.user = user
	      e_account.save!
	    rescue => ex
        Bugsnag.notify(ex)
	      puts "----------------------> Unable to create <----------------------"
	      p ex.message
	      false
	    end
	end

  def show_email
    if params[:provider] == 'google'
      @email = @api_client.get_details(params[:id])
    end

    @m_type = params[:mailbox]
   
    render partial: 'show_email', status: :ok
  end

  def send_mail
    if params[:provider] == 'google'
      sent = @api_client.send_mail(params)
    end
    if params[:from].present?
      #mail_letter = MailLetter.create :organization_id => current_user.organization.id, :mailto => params[:to], :subject => params[:subject], :description => params[:body], :mail_by => current_user.id, :mail_cc => params[:cc], :mail_bcc => params[:bcc]
    end
      #render nothing: true, status: :no_content
      render json: {message: "success"}, status: :ok
  end


  def reply_mail
    begin 
      sent = @api_client.send_mail(params)
      render json: {message: "success"}, status: :ok
    rescue => e
      # Bugsnag.notify(e)
      puts "---------> reply mail error message <---------"
      p e.message
    end
  end

  def toggle_star
    result = @api_client.toggle_star(params[:id], params[:starred] == 'true')
    render json: {result: result}, status: :ok
  end

  def toggle_unread
    result = @api_client.toggle_unread(params[:ids], params[:unread].to_s == 'true')
    render json: {result: result}, status: :ok
  end

  def delete_emails
    result = @api_client.delete_emails(params[:ids])
    render json: {result: result}, status: :ok
  end

  def logout
    @current_user.email_account.destroy if @current_user.email_account
    @current_user.update_attributes({:smtp_config => "", :email_setup_at => ""}) if @current_user.smtp_config == "google"
    redirect_to email_connect_path, notice: 'Successfully logged out from email.'
  end

  def failure
    redirect_to email_connect_path
  end 

  def setup_email_with_inset
    @current_user.update_attributes({:smtp_config => "inset", :email_setup_at => Time.now})
    flash[:notice] = "Email setup successfully."
    redirect_to "/"
  end

  private

  def unset_side_panel
    @disable_side_panel = true
  end

  def set_up_api
    begin
      p "coming to set_up_api ...................."
      account = @current_user.email_account
      p "get account ...................."
      redirect_to email_connect_path and return unless account.present?
      p "no redirect ...................."
      account.refresh_access_token! if account.access_token_expired?
      p "account.refresh executed ...................."
      if params[:provider] == 'google'
        p "api_client is executed...................."
        @api_client = GmailClient::Gmail.new(account.access_token, account.email)
      else
        redirect_to email_connect_path, notice: 'Email provider is not supported by this application. Please contact the administrator.'
      end
    rescue  =>ex
      p ex.message
    end
  end
  def office
    token = get_offic_access_token
    if token
      # If a token is present in the session, get events from the calendar
      callback = Proc.new do |r| 
        r.headers['Authorization'] = "Bearer #{token}"
      end

      graph = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
                                cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
                                &callback)

      @events = graph.me.events.order_by('start/dateTime asc')
    else
      # If no token, redirect to the root url so user
      # can sign in.
      redirect_to root_url
    end
  end
end
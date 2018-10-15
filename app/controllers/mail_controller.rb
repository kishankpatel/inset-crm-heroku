# Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See LICENSE.txt in the project root for license information.

class MailController < ApplicationController

  include AuthHelper
  before_filter :set_up_office_api, except: [:index,:connect,:get_mail,:message_read, :logout]

  @@office_messages_count = 10
  def index
    # p @current_user
    # p @current_organization
    offmail = OfficeMail.where(:user_id=>@current_user.id,:organization_id=>@current_organization.id).first
    
    if(offmail.present?)
      token = get_office_access_token offmail.token_hash,@current_user,@current_organization
   
      if token
        # If a token is present in the session, get messages from the inbox
        callback = Proc.new do |r| 
          r.headers['Authorization'] = "Bearer #{token}"
        end

        graph = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
                                   cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
                                   &callback)

         # graph = MicrosoftGraph.new(base_url: "https://graph.microsoft.com/v1.0",
        #                      cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, "metadata_v1.0.xml"),
        #                      &callback)
        me = graph.me # get the current user
        # puts "Hello, I am #{me.display_name}."
        if(!offmail.office_mail.present?)
          offmail.office_mail = graph.me.user_principal_name
          offmail.save
        end
        #graph = MicrosoftGraph.new({base_url: 'https://graph.microsoft.com/v1.0', cached_metadata_file: File.join(Rails.root, 'data','metadata_v1.0.xml')},  &callback)
        @labels = graph.me.mail_folders
        # graph.me.mail_folders.each do |mf|
        #   p mf.display_name
        #   p mf.
        # end

        # @messages = graph.me.mail_folders.find('inbox').messages({"$top"=>2, "$skip"=>5}).order_by('receivedDateTime desc')
      else
        # If no token, redirect to the root url so user
        # can sign in.
        redirect_to root_url
      end
    else
      redirect_to get_login_url
    end
  end
  def connect
    account = @current_user.office_mail
    redirect_to office365_mails_path if account.present?
  end

  def get_mail
    mailbox = params[:mailbox]
	if params[:mailbox] == "SentItems"
	  @m_type = "sent"
	else
	  @m_type = "inb"
	end
    offmail = OfficeMail.where(:user_id=>@current_user.id,:organization_id=>@current_organization.id).first
    token = get_office_access_token offmail.token_hash,@current_user,@current_organization
    if token
      # If a token is present in the session, get messages from the inbox
      callback = Proc.new do |r| 
        r.headers['Authorization'] = "bearer #{token}"
      end

      graph = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
                                 cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
                                 &callback)
      me = graph.me # get the current user

      # @emails = graph.me.mail_folders.find(mailbox).messages().order_by('receivedDateTime desc')

      
        # @messages = graph.me.mail_folders.find('inbox').messages({"$top"=>2, "$skip"=>5}).order_by('receivedDateTime desc')

      if params[:current_page_id].present?
        @current_page_id = params[:current_page_id].to_i
      else
        @current_page_id = 0
      end

      skip = (@current_page_id * @@office_messages_count)
      if @current_page_id > 0
        path = "/me/mailfolders/#{mailbox}/messages?select=Subject,Sender,ReceivedDateTime,IsRead,HasAttachments&$orderby=ReceivedDateTime desc&$top=#{@@office_messages_count}&$skip=#{skip}"
      else
        path = "/me/mailfolders/#{mailbox}/messages?select=Subject,Sender,ReceivedDateTime,IsRead,HasAttachments&$orderby=ReceivedDateTime desc&$top=#{@@office_messages_count}"
      end
      emails = graph.service.get("#{path}")
      @emails = emails[:attributes]["value"]
      if emails[:attributes]["@odata.next_link"].present?
        @next_page = true
      else
        @next_page = false
      end
      puts "...............................count ............................"
      render :partial=>'mailbox_messages',:locals=>{emails: @emails}
    else
      # If no token, redirect to the root url so user
      # can sign in.
      redirect_to root_url
    end
  end
  
  def message_read
    message_id = params[:message_id]
    offmail = OfficeMail.where(:user_id=>@current_user.id,:organization_id=>@current_organization.id).first
    token = get_office_access_token offmail.token_hash,@current_user,@current_organization
    
	if params[:mtype] == "sent"
	  @m_type = "sent"
	else
	  @m_type = "inb"
	end
	
	if token
      # If a token is present in the session, get messages from the inbox
      callback = Proc.new do |r| 
        r.headers['Authorization'] = "bearer #{token}"
      end

      graph = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
                                 cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
                                 &callback)
     

      @email = graph.me.messages.find(message_id)
      if(params[:is_read] == "false")
        puts "coming to patch .............................."
        @email.is_read = true
        @email.save!()
      end
      
      render :partial=>'show_email',:locals=>{email: @email}
    end
  end
  # def toggle_unread
  #   message_id = params[:message_id]
  #   offmail = OfficeMail.where(:user_id=>@current_user.id,:organization_id=>@current_organization.id).first
  #   token = get_office_access_token offmail.token_hash,@current_user,@current_organization
  #   if token
  #     # If a token is present in the session, get messages from the inbox
  #     callback = Proc.new do |r| 
  #       r.headers['Authorization'] = "bearer #{token}"
  #     end

  #     graph = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
  #                                cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
  #                                &callback)
     

  #     @email = graph.me.messages.find(message_id)
      
  #     @email.is_read = true
  #     render :text=>"success"
  #   end
  # end
  def send_office_mail
    template = {
      subject: params[:subject],
      body: {
        contentType: "html",
        content: params[:body],
      },
      to_recipients: [
        { email_address: { address: params[:to]} },
      ],
      }
      if(params[:cc].present?)
        template[:ccRecipients] = [{ "emailAddress": {address:  params[:cc]} }]
     
      end
      if(params[:bcc].present?)
        template[:bccRecipients] = [{ "emailAddress": {address:  params[:bcc]} }]
    
      end
    
    attachments = []

    if(params[:files].present?)
      params[:files].each do |file|
        if file.present?
          content_of_file =Base64.encode64(file.read)
          attachments << 
          {
            "@odata.type": "#microsoft.graph.fileAttachment",
            "name": file.original_filename,
            "contentBytes": content_of_file 
          }
        end

       end
    end
    template[:attachments] = attachments
    sent = @graph_api.me.send_mail(message: template)
   
    render json: {message: "success"}, status: :ok
  end
  def toggle_unread
    begin 
      puts "getting output ..............................."

      message_ids = params[:ids].split(",")
      message_ids.each do |message_id|
        @email = get_message(message_id)
        # p @email
        @email.is_read = params[:read] == "true" ? true : false
        @email.save!()
      end
      # @message.create_reply(template)
      render json: {message: "success"}, status: :ok
     rescue => e
      puts "---------> reply mail error message <---------"
      p e.message
      render json: {message: e.message}, status: "error"
    end
  end
  def delete_emails
    begin 
      puts "getting output ..............................."

      message_ids = params[:ids].split(",")
      message_ids.each do |message_id|
        @email = get_message(message_id)
        @email.delete!
        
      end
      # @message.create_reply(template)
      render json: {message: "success",result: ""}, status: :ok
     rescue => e
      puts "---------> reply mail error message <---------"
      p e.message
      render json: {message: e.message}, status: "error"
    end
  end
  def reply_office_mail
    begin 
      template = generate_template(params)
      @message = get_message(params[:reply_to_message_id])
      @message.create_reply(template)
      render json: {message: "success"}, status: :ok
     rescue => e
      puts "---------> reply mail error message <---------"
      p e.message
    end
  end
  def forward_office_mail
    begin 
      template = generate_template(params)
      @message = get_message(params[:reply_to_message_id])
      @message.forward(template)
      render json: {message: "success"}, status: :ok
    rescue => e
      puts "---------> forward mail error message <---------"
      p e.message
    end
  end

  def logout
    @current_user.office_mail.destroy if @current_user.office_mail
    redirect_to mail_connect_path, notice: 'Successfully logged out from office365.'
  end

  private
  def set_up_office_api
    begin
      p "coming to set_up_api ...................."
      offmail = @current_user.office_mail
      p "get account ...................."
      redirect_to mail_connect_path and return unless offmail.present?
      p "no redirect ...................."
      token = get_office_access_token offmail.token_hash,@current_user,@current_organization
      if token
      # If a token is present in the session, get messages from the inbox
        callback = Proc.new do |r| 
          r.headers['Authorization'] = "bearer #{token}"
        end

        @graph_api = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
                                   cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
                                   &callback)
        
      else
        redirect_to email_connect_path, notice: 'Email provider is not supported by this application. Please contact the administrator.'
      end
    rescue  =>ex
      p ex.message
    end
  end
  def get_message(message_id)
    set_up_office_api
    @email = @graph_api.me.messages.find(message_id)
    
    return @email
  end
  def generate_template(parms)
    template = {
      subject: parms[:subject],
      body: {
        content: parms[:body],
      },
      to_recipients: [
        { email_address: { address: parms[:to]} },
      ],
    }
    if(parms[:cc].present?)
      template[:ccRecipients] = [{ "emailAddress": {address:  parms[:cc]} }]
    # ccRecipients: [
    #   { "emailAddress": {address:  params[:cc]} },
    # ],
    end
    if(parms[:bcc].present?)
      template[:bccRecipients] = [{ "emailAddress": {address:  parms[:bcc]} }]
    # bccRecipients: [
    #   { "emailAddress": {address:  params[:bcc]} },
    # ],
    end
    return template
  end
end
require "net/http"
require "net/https"
module AuthHelper

  # App's client ID. Register the app in Application Registration Portal to get this value.
  # CLIENT_ID = '5f656a86-bdb7-46bb-975a-130b848bbed1'
  # App's client secret. Register the app in Application Registration Portal to get this value.
  # CLIENT_SECRET = 'nvudU842$[$vhwNUZDEK74+'
  CLIENT_ID = OFFICE_CONFIG["client_id"]
  CLIENT_SECRET = OFFICE_CONFIG["client_secret"]
  GRAPH_HOST = 'https://graph.microsoft.com'.freeze

  # Scopes required by the app
  SCOPES = [ 'openid',
             'profile',
             'offline_access',
             'User.Read',
             'Mail.Read',
             'Calendars.Read',
             'Contacts.Read',
             'Mail.Send',
             'Mail.ReadWrite',
             'Calendars.ReadWrite'
              ]

  # Generates the login URL for the app.
  def get_login_url
    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => "https://login.microsoftonline.com",
                                :authorize_url => "/common/oauth2/v2.0/authorize",
                                :token_url => "/common/oauth2/v2.0/token")
                                # :authorize_url => "/oauth2/v2.0/authorize",
                                # :token_url => "/oauth2/v2.0/token")
                                # :authorize_url => "/auth/office365/callback",
                                # :token_url => "/oauth2/v2.0/token"
                                # )
# /auth/office365/callback

    login_url = client.auth_code.authorize_url(:redirect_uri => office365_callback_url, :scope => SCOPES.join(' '))
  end
  def get_office_access_token token_hash,user,organization
  # Get the current token hash from session
  #token_hash = session[:azure_token]

  client = OAuth2::Client.new(CLIENT_ID,
                              CLIENT_SECRET,
                              :site => 'https://login.microsoftonline.com',
                              :authorize_url => '/common/oauth2/v2.0/authorize',
                              :token_url => '/common/oauth2/v2.0/token')
  token = OAuth2::AccessToken.from_hash(client, token_hash)

  # Check if token is expired, refresh if so
  if token.expired?
    new_token = token.refresh!
    # Save new token
    #session[:azure_token] = new_token.to_hash  
    offmail = OfficeMail.where(:user_id=>user.id,:organization_id=>organization.id).first
    offmail.token_hash = new_token.to_hash
    offmail.token = new_token.token
    offmail.save
    access_token = new_token.token
  else
    access_token = token.token
  end
end
# Exchanges an authorization code for a token
  def get_token_from_code(auth_code)
    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v2.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')
                                # :authorize_url => "/auth/office365/callback")
                                
    token = client.auth_code.get_token(auth_code,
                                       :redirect_uri => office365_callback_url,
                                       :scope => SCOPES.join(' '))
  end
  def get_basic_info_office email
    
    {
        subject: email.subject,
        from: email.from,
        to: email.to_recipients,
        received: email.received_date_time,
        
        attachment: email.has_attachments,
        unread: !email.is_read,
        # starred: email['labelIds'].include?('STARRED'),
        id: email.id,
        msg_id: email.id,
        in_reply_to: email.reply_to,
        cc: email.cc_recipients,
        bcc: email.bcc_recipients
    }
  end
  def get_email_content_office(email)
    payload = email
    email_body =
        begin
          p payload.body.content_type
          case payload.body.content_type
            when 'html', 'text'
              fetch_from_html_office(payload)
            when 'multipart/alternative'
              fetch_from_alternative_office(payload)
            when 'multipart/mixed'
              fetch_from_mixed_office(payload)
            when 'multipart/related'
              fetch_from_related_office(payload, email['id'])
            else
              "<strong class='text-danger'>Could not recognize the email content.</strong>"
          end
        rescue => ex
          p ex.message
          "<strong class='text-danger'>Unable to parse email body.</strong>"
        end
    email_body.force_encoding('UTF-8').html_safe
  end
  def fetch_from_html_office(payload)
    encoded_body = payload.body.content
    # Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end
  def fetch_from_alternative_office(payload)
    parts = payload['parts']
    html_part = parts.select { |part| part['mimeType'] == 'text/html' }[0]
    encoded_body = html_part['body']['data']
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end
  def fetch_from_mixed_office(payload)
    parts = payload['parts'].select { |part| part['mimeType'] == 'multipart/alternative' }[0]
    parts = parts.present? ? parts['parts'] : payload['parts']
    html_part = parts.select { |part| part['mimeType'] == 'text/html' }[0]
    encoded_body = html_part['body']['data']
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end

  def fetch_from_alternative_office(payload)
    parts = payload['parts']
    html_part = parts.select { |part| part['mimeType'] == 'text/html' }[0]
    encoded_body = html_part['body']['data']
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end
  def generate_office_forward_content(content, basic_info)
    p basic_info
    if(basic_info.present?)
      str = ''
      str += '---------- Forwarded message ----------<br/>'
      str += 'From: '+ (basic_info[:from].email_address.address) +'<br/>'
      str += 'Subject: '+  basic_info[:subject] +'<br/>'
      str += 'To: '+ ((to=basic_info[:to]).present? ? to.map{|tom| tom.email_address.address}.join(",") : "") +'<br/><br/><br/>'
      cnt = Nokogiri::HTML(content)
      cnt.at_xpath("//body")
      #tr += content
      str.html_safe + cnt
    end
  end

  def get_graph_api(user)
    offmail = user.office_mail
    if(offmail.present?)
      p "get account ...................."
      redirect_to mail_connect_path and return unless offmail.present?
      p "no redirect ...................."
      token = get_office_access_token offmail.token_hash,user,user.organization
      if token
      # If a token is present in the session, get messages from the inbox
        callback = Proc.new do |r| 
          r.headers['Authorization'] = "bearer #{token}"
        end

        graph_api = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
                                   cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
                                   &callback)
        return graph_api
      else
        return nil
      end
    end
  end
  def set_contact_mail_letters(user)
    graph_api = get_graph_api(user)
    if(graph_api.present?)
      ## reading mail from "inbox" folder
      save_mail_to_mail_letters graph_api,'inbox',user
      ## reading mail from "Sent" folder
      save_mail_to_mail_letters graph_api,'SentItems',user

    end ## graph api exists check end
  end
  def save_mail_to_mail_letters graph_api,mail_box,user
    if(mail_box == 'inbox')
      @emails = graph_api.me.mail_folders.find(mail_box).messages.order_by('receivedDateTime desc')
    else
      @emails = graph_api.me.mail_folders.find(mail_box).messages.order_by('sentDateTime desc')
    end
      @emails.each do |email|
        exists = MailLetter.where("mail_domain = 'Office365' and mail_id = ?",email.id).exists?
        if(exists)
          break
        else

          ##check if the mail is from any client/contacts
          from_email_id = email.from.email_address.address
          p from_email_id
          to_email_ids = email.to_recipients.map{|to| to.email_address.address}
          cc_email_ids = email.cc_recipients.map{|cc| cc.email_address.address}
          if(mail_box == 'inbox')
            indi_contacts = user.organization.individual_contacts.where("email = ? or email in (?) ",from_email_id,cc_email_ids).all
          else
            indi_contacts = user.organization.individual_contacts.where("email in (?) or email in (?) ",cc_email_ids,to_email_ids).all
          end
          if(indi_contacts.present?)
            puts "indi_contacts exists ..........................."
            # users = User.where(:email=>  to_email_ids).all
            indi_contacts.each do |indi_contact|
              #:description, :mail_bcc, :mail_by, :mail_cc, :mailable_id, :mailable_type, 
              #:mailto, :subject,:organization,:organization_id,:mailable,:contact_info
              
              basic_info = get_basic_info_office(email)
              ml = MailLetter.new({
                description: get_email_content_office(email),
                mail_bcc: basic_info[:bcc].present? ? basic_info[:bcc].map{|bcc| bcc.email_address.name}.join(",") : "",
                mail_by: user.id,
                mail_cc: basic_info[:cc].present? ? basic_info[:cc].map{|cc| cc.email_address.name}.join(",") : "",
                mailable: indi_contact,
                mailto: basic_info[:to].present? ? basic_info[:to].map{|to| to.email_address.name}.join(",") : "",
                subject: basic_info[:subject],
                organization_id: user.organization_id,
                mail_domain: "Office365",
                mail_id: email.id,
                mail_from: from_email_id
                })
              puts "...................mail contacts....................."
              ml.save
              p ml
            end
          else
            puts "no indi_contacts exists ..........................."
          end ## individual_contacts loop end
        end ## checking if the mail letter exists
      end ## email loop end
  end
  def add_event_to_office365_calendar(user,event)
    puts "coming to add event to office365 calendar.................."
    graph_api = get_graph_api(user)
    if(graph_api.present?)
      event_id = graph_api.me.events.create!(event)
      puts  "event created .........................................."
      return event_id
    end
  end
  def get_token_from_user user
    offmail = user.office_mail
    if(offmail.present?)
      redirect_to mail_connect_path and return unless offmail.present?
      token = get_office_access_token offmail.token_hash,user,user.organization
    end
  end
  def update_event_to_office365_calendar(user,event_id,request_params)
    
    get_events_url = "/v1.0/me/events/#{event_id}"
    token = get_token_from_user user
    
    response = make_https_api_call get_events_url, token, request_params,'patch'
  end
  def get_calendar_events(user,start_time,end_time)
    graph_api = get_graph_api(user)
    if(graph_api.present?)
      # events = graph_api.me.events
      # events.each do |event|
      #   puts event.subject
      #   puts event.id
      # end
      return graph_api.me.events
    end
  end
  def delete_event_from_office365_calendar(user,event_id)
    get_events_url = "/v1.0/me/events/#{event_id}"
    token = get_token_from_user user
    response = make_https_api_call get_events_url, token, {},'delete'
  end
  # def get_calendar_events(user,start_time,end_time)
  #   offmail = user.office_mail
  #   if(offmail.present?)
  #     p "get account ...................."
  #     redirect_to mail_connect_path and return unless offmail.present?
  #     p "no redirect ...................."
  #     token = get_office_access_token offmail.token_hash,user,user.organization
  #     p token
  #   end
  #   get_events_url = '/api/v2.0/me/events'

  #   query = {
  #     '$select'=> 'Subject,Organizer,Start,End',
  #     '$startDateTime'=> start_time,
  #     '$endDateTime'=> end_time,
  #     '$orderby'=> 'createdDateTime DESC'
  #   }

  #   response = make_api_call get_events_url, token, query
  #   p response
  #   # raise response.parsed_response.to_s || "Request returned #{response.code}" unless response.code == 200
  #   # response.parsed_response['value']
  # end
  private
  def make_api_call(endpoint, token, params = nil, method='get')
    # headers = {
    #   "Authorization"=> "Bearer #{token}"
    # }

    # query = params || {}
    # puts "response from make api call"
    # if(method == 'get')
    # response = HTTParty.get "#{GRAPH_HOST}#{endpoint}",
    #              headers: headers,
    #              query: query
    # elsif method == 'patch'
    #   response = HTTParty.patch "#{GRAPH_HOST}#{endpoint}",
    #              headers: headers,
    #              body: query
    # end
      
    # p response
    # return response
  end
  def make_https_api_call(endpoint, token, request_params = nil, method='get')

    url = "#{GRAPH_HOST}#{endpoint}"
    

    uri = URI.parse(url)

    # response = Net::HTTP.new(uri.host, uri.port)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    if(method == 'get')
      response = http.get(
            uri.path,
            request_params.to_json,
            'Authorization' => "Bearer #{token}",
            'Content-Type' => 'application/json'
        )
    elsif method == 'patch'
      puts "coming to patch the request......................"
      p request_params
      response = http.patch(
              uri.path,
              request_params.to_json,
              'Authorization' => "Bearer #{token}",
              'Content-Type' => 'application/json'
          )
    elsif method == 'delete'
      response = http.delete(
              uri.path,
              'Authorization' => "Bearer #{token}",
              'Content-Type' => 'application/json'
          )
    end
    p response
    return response
  end
end
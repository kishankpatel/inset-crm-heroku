module EmailHelper
  def get_email_content(email)
    payload = email['payload']
    email_body =
        begin
          case payload['mimeType']
            when 'text/html', 'text/plain'
              fetch_from_html(payload)
            when 'multipart/alternative'
              fetch_from_alternative(payload)
            when 'multipart/mixed'
              fetch_from_mixed(payload)
            when 'multipart/related'
              fetch_from_related(payload, email['id'])
            else
              "<strong class='text-danger'>Could not recognize the email content.</strong>"
          end
        rescue => ex
          p ex.message
          "<strong class='text-danger'>Unable to parse email body.</strong>"
        end
    email_body.force_encoding('UTF-8').html_safe
  end

  def generate_forward_content(content, basic_info)
    str = ''
    str += '---------- Forwarded message ----------<br/>'
    str += 'From: '+ (basic_info[:from].split('<').first.strip) +'<br/>'
    str += 'Subject: '+  basic_info[:subject] +'<br/>'
    str += 'To: '+ ((to=basic_info[:to].split('<')).present? ? to.first.strip : "") +'<br/><br/><br/>'
    cnt = Nokogiri::HTML(content)
    cnt.at_xpath("//body")
    #tr += content
    str.html_safe + cnt
  end

  def generate_reply_content(content, basic_info)
    #str = '<br/><br/>------'
    str = ''    
    str += '<blockquote style="margin:5px 0"><br/>'
    str += '</blockquote>'
    #str += content
    cnt = Nokogiri::HTML(content)
    cnt.at_xpath("//body")    
    str.html_safe + cnt
  end


  def fetch_from_related(payload, id)
    parts = payload['parts'].select { |part| part['mimeType'] == 'multipart/alternative' }[0]['parts']
    html_part = parts.select { |part| part['mimeType'] == 'text/html' }[0]
    encoded_body = html_part['body']['data']

    attachment_parts = payload['parts'].select { |part| part['mimeType'] != 'multipart/alternative' }

    attachments = []
    attachment_parts.each do |part|
      attachment_id = part['body']['attachmentId']
      attachment = Base64.urlsafe_decode64(@api_client.get_attachment(id, attachment_id))
      attachments << "<img src='data:#{part['mimeType']};base64,#{Base64.encode64(attachment)}'/>"
    end
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '') + '<br>' + attachments.join('')
  end

  def fetch_from_mixed(payload)
    parts = payload['parts'].select { |part| part['mimeType'] == 'multipart/alternative' }[0]
    parts = parts.present? ? parts['parts'] : payload['parts']
    html_part = parts.select { |part| part['mimeType'] == 'text/html' }[0]
    encoded_body = html_part['body']['data']
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end

  def fetch_from_alternative(payload)
    parts = payload['parts']
    html_part = parts.select { |part| part['mimeType'] == 'text/html' }[0]
    encoded_body = html_part['body']['data']
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end

  def fetch_from_html(payload)
    encoded_body = payload['body']['data']
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end

  def get_header_attribute(gmail_data, attribute)
    begin
      headers = gmail_data['payload']['headers']     
      array = headers.reject { |hash| hash['name'] != attribute }
      array.first.present? ? array.first['value'] : ''
    rescue
      ''
    end
  end

  def get_email_communicators(email)
    data = {
        from: get_header_attribute(email, 'From').match(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).to_s,
        to: get_header_attribute(email, 'To').match(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).to_s,
        received: get_header_attribute(email, 'Received').split(';').pop.strip.to_datetime.to_i
    }
    p data
    return data
  end

  def get_basic_info(email)
    {
        subject: get_header_attribute(email, 'Subject'),
        from: get_header_attribute(email, 'From'),
        to: get_header_attribute(email, 'To'),
        received: get_header_attribute(email, 'Received').split(';').pop.present? ? get_header_attribute(email, 'Received').split(';').pop.strip.to_datetime.to_i : "",
        snippet: email['snippet'],
        attachment: get_header_attribute(email, 'X-MS-Has-Attach').present?,
        unread: email['labelIds'].include?('UNREAD'),
        starred: email['labelIds'].include?('STARRED'),
        id: email['id'],
        msg_id: get_header_attribute(email, 'Message-ID').present? ? get_header_attribute(email, 'Message-ID') : get_header_attribute(email, 'Message-Id'),
        in_reply_to: get_header_attribute(email, 'Reply-to').present? ? get_header_attribute(email, 'Reply-to') : get_header_attribute(email, 'From'),
        cc: get_header_attribute(email, 'Cc'),
        bcc: get_header_attribute(email, 'Bcc')
    }
  end
  def get_google_service_api user
    @google_client = Google::APIClient.new(:application_name => 'InsetCRM',:application_version => '1.0.0')
    @google_client.authorization.access_token = user.email_account.fresh_token
    service = @google_client.discovered_api('calendar', 'v3')
    return service
  end
  def get_google_calendar_events(user, start_date,end_date ) 
    service = get_google_service_api user
    result = @google_client.execute(:api_method => service.events.list,
      :parameters => {'calendarId' => user.email,timeMin: start_date.to_datetime.rfc3339, timeMax: end_date.to_datetime.rfc3339  },
      :headers => {'Content-Type' => 'application/json'})
    items = result.data.items
  end
  def update_event_to_google_calendar(user,event_id,request_params)
    service = get_google_service_api user
    result = @google_client.execute(:api_method => service.events.update,
      :parameters => {'calendarId' => user.email,eventId: event_id},
      :body => JSON.dump(request_params),
      :headers => {'Content-Type' => 'application/json'})
    result
  end
  def delete_event_from_google_calendar(user,event_id)
    service = get_google_service_api user
    result = @google_client.execute(:api_method => service.events.delete,
      :parameters => {'calendarId' => user.email,eventId: event_id},
      :headers => {'Content-Type' => 'application/json'})
    result
  end
end


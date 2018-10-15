#
require 'base64'
require 'faraday'
require 'google/api_client'
#
module GmailClient
  class Gmail
    attr_accessor :access_token

    def initialize(access_token, email)
      @access_token = access_token
      @client = Google::APIClient.new({application_name: 'Wakeupsales', application_version: '1.0'})
      @client.authorization.access_token = @access_token
      @service = @client.discovered_api('gmail')
      @email = email
    end

    def fetch_labels
      begin
        result = @client.execute(
            :api_method => @service.users.labels.list,
            :parameters => {'userId' => 'me'},
            :headers => {'Content-Type' => 'application/json'}
        )
        JSON.parse(result.body)['labels']
      rescue => ex
        p ex.message
      end
    end

    def fetch_label_by_id(label_id)
      begin
        result = @client.execute(
            :api_method => @service.users.labels.get,
            :parameters => {'userId' => 'me', id: label_id},
            :headers => {'Content-Type' => 'application/json'}
        )
        JSON.parse(result.body)
      rescue => ex
        p ex.message
      end
    end

    def fetch_emails_by_label(label_id, options = {})    
      begin
        emails = []
        result = @client.execute(
            :api_method => @service.users.messages.list,
            :parameters => {userId: 'me', labelIds: label_id}.merge(options),
            :headers => {'Content-Type' => 'application/json'}
        )

        parsed_result = JSON.parse(result.body)
        messages = parsed_result['messages'] || []
        messages.each do |msg|
          emails << get_details(msg['id'])
        end
      rescue => ex
        p ex.message
      end
      return emails, parsed_result['nextPageToken'].to_s
    end

    def search_emails(options = {})
      begin
        emails = []
        result = @client.execute(
            :api_method => @service.users.messages.list,
            :parameters => {userId: 'me'}.merge(options),
            :headers => {'Content-Type' => 'application/json'}
        )
        parsed_result = JSON.parse(result.body)
        messages = parsed_result['messages'] || []
        messages.each do |msg|
          emails << get_details(msg['id'])
        end
      rescue => ex
        p ex.message
      end
      return emails, parsed_result['nextPageToken'].to_s
    end

    def get_details(msg_id)
      begin
        result = @client.execute(
            :api_method => @service.users.messages.get,
            :parameters => {userId: 'me', id: msg_id, format: 'full'},
            :headers => {'Content-Type' => 'application/json'}
        )
        JSON.parse(result.body)
      rescue => ex
        p ex.message
        {}
      end
    end

    def get_attachment(msg_id, attachment_id)
      begin
        result = @client.execute(
            :api_method => @service.users.messages.attachments.get,
            :parameters => {userId: 'me', messageId: msg_id, id: attachment_id},
            :headers => {'Content-Type' => 'application/json'}
        )
        JSON.parse(result.body)['data']
      rescue => ex
        p ex.message
        ''
      end
    end

    def toggle_star(msg_id, starred = true)
      begin
        payload = starred ? {'removeLabelIds' => ['STARRED']} : {'addLabelIds' => ['STARRED']}
        result = @client.execute(
            :api_method => @service.users.messages.modify,
            :parameters => {userId: 'me', id: msg_id},
            :headers => {'Content-Type' => 'application/json'},
            :body => payload.to_json
        )
        result.success?
      rescue => ex
        p ex.message
        false
      end
    end

    def toggle_unread(msg_ids, unread = true)
      begin
        payload = unread ? {'addLabelIds' => ['UNREAD']} : {'removeLabelIds' => ['UNREAD']}
        msg_ids.split(',').each do |id|
          @client.execute({
                              :api_method => @service.users.messages.modify,
                              :parameters => {userId: 'me', id: id},
                              :headers => {'Content-Type' => 'application/json'},
                              :body => payload.to_json
                          })
        end
      rescue => ex
        p ex.message
        false
      end
    end

    def delete_emails(msg_ids)
      begin
        payload = {ids: msg_ids.split(',')}
        result = @client.execute(
            :api_method => @service.users.messages.batch_delete,
            :parameters => {userId: 'me'},
            :headers => {'Content-Type' => 'application/json'},
            :body => payload.to_json
        )
        result.success?
      rescue => ex
        p ex.message
        false
      end
    end

    def send_mail(options)
      # puts "--------send email"
      begin
        email = build_mail(options)
        result = @client.execute(
            :api_method => @service.users.messages.discovered_methods.select { |m| m.name == 'send' }.first,
            :parameters => {userId: 'me'},
            :headers => {'Content-Type' => 'application/json'},
            :body => {raw: Base64.urlsafe_encode64(email.to_s)}.to_json
        ) if email.present?
        # puts "---------------------> send_mail <--------------------"
        # result1 = @client.execute(
        #     :api_method => @service.users.messages.get,
        #     :parameters => {userId: 'me', id: JSON.parse(result.body)['id'], format: 'full'},
        #     :headers => {'Content-Type' => 'application/json'}
        # )
        # emails = JSON.parse(result1.body)
        # p emails
        # p get_hd_attributes(emails, 'To')
        # puts "-------------------------------------------------------"
      rescue => ex
        p ex.message
        false
      end
    end

    def build_mail(options)
      begin
        email = Mail.new
        email.to = options[:to]
        email.cc = options[:cc]
        email.bcc = options[:bcc]
        email.subject = options[:subject]
        if options[:is_reply_message] == "true"
          email.in_reply_to = options[:reply_to_message_id]
        else
          email.from = @email
          email.date = Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')
        end

        html_part = Mail::Part.new do
          content_type('text/html; charset=UTF-8')
          body(options[:body].gsub("\n", ''))
        end

        email.html_part = html_part
        (options['files'] || []).each do |file|
          email.attachments[file.original_filename] = {:mime_type => file.content_type, :content => file.read}
          # email.add_file({filename: file.original_filename, content: file.read})
        end
        email
      rescue
        nil
      end
    end
  end
end
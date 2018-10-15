# require 'rubygems'
# require 'mandrill'
# namespace :wus do
#   task :send_welcome_test => :environment do 
#   	 include Mandrill
#   	 mandrill = Mandrill::API.new MANDRILL_API
#   	 template_name = "test"
#   	  template_content = [
#       { "name"=>"user_name", "content"=>"Hi, krishna!"},
#      ]
#      mail_subject = "WakeUpSales:: Welcomes you"
#      message = {"to"=>[{"name"=> "krishna" , "email"=> 'krishna.sahoo@andolasoft.com'}],
                 
#                  "track_opens"=> true,
#                  "track_clicks"=> true,
#                  "important"=> false,
                 
#                  "subject"=> mail_subject,
#                  "auto_html"=> nil,
#                  "inline_css"=> true,
#                  "from_email"=> "support@wakeupsales.org",
#                  "headers"=> {"Reply-To"=>"test@andolasoft.com"},
#                  "from_name"=> "WakeUpSales",
#                  "merge"=> true,
#                  "global_merge_vars"=> [
#                   {
#                       "name"=> "",
#                       "content"=> ""
#                   }]
                  
#                }
      
#       async = false
#       ip_pool = "Main Pool"
#       result = mandrill.messages.send_template template_name, template_content, message, async, ip_pool
#   end
# end
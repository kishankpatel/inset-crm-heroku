module CommunityPluginsHelper
	def return_zip_file plugin_name
		case plugin_name
		when 'Sendgrid'
		  "wus_sendgrid.zip"
		when 'Amazon SES'
		  "wus_amazon_ses.zip"
		when 'Invoice'
		  "wus_invoice.zip"
		when 'Web to Lead'
		  "wus_web_form.zip"
		when 'Gmail Mailbox'
		  "wus_mailbox.zip"
		when 'Lead Project Management'
		  "wus_lead_project_management.zip"
		else
		  nil
		end
	end
end
namespace :wus do  
  
  #Insert plugin integration to plugins table
  task :insert_plugin_integrations => :environment do
    Plugin.create(title: "Invoice Generator", description: 'WakeUpSales added a new feature "Generate Invoice". Using that you can send an invoice to your existing contact or any new user. You can track all payments received from a particular contact. You can choose your current during invoice generate.', is_active: true)
    Plugin.create(title: "Google Calendar", description: "OmniAuth with Google into current Devise setup and then, used the Google Calendar API to interact with my Rails App. Successful creation of an Events entry will toggle the app to send an API request to create a Google Calendar request so that a Google Calendar Event gets created every time an Event from my Rails API gets created. They will be in two places, but will only need to input the Event data once.", is_active: true)
  	Plugin.create(title: "Email Tracker", description: "Email tracking is a method for monitoring the email delivery to intended recipient. It tracks the click/open view counts of the emails sent to the users email. Email tracking is useful when the sender wants to know if the intended recipient actually received the email, or if they clicked the links.", is_active: true)
  	
  	Plugin.create(title: "Import Gmail Contacts", description: "Google conatct API is integrated in WakeUpSales CRM application Completely FREE. You can import all your gmail contacts by just one click. & convert your contacts to leads. We are providing a complete setup & installation Guide.", is_active: true)
  	Plugin.create(title: "Website Integration", description: "WakeUpSales CRM tool is now available with website integration API. You can integrate with your contact us page, so that you can track the inbound leads efficiently. We are providing an integration guide Completely FREE.", is_active: true)
  	Plugin.create(title: "Zapier Integration", description: "Zapier enables you to automate tasks between other online apps like Basecamp and Gmail. It lets you easily connect the web apps you use, making it easy to automate tedious tasks. A Zap is made up of a Trigger and one or more Actions or Searches.", is_active: true)
  	Plugin.create(title: "Segment integration", description: "Segment is trusted by thousands of companies as their customer data hub. Collect user data with one API and send it to hundreds of tools or a data warehouse.", is_active: true)
  	Plugin.create(title: "Mailchimp Integration", description: "Create integrations that connect MailChimp to a CMS, blog, shopping cart, and more. Our API offers in-depth documentation, a download section for various wrappers, and how-to documents.The majority of data and functionality within our web application is accessible, so the integration possibilities are endless.", is_active: true)
  	Plugin.create(title: "Managing email inbox", description: "Manage your email inbox from your CRM Tool. You can view your Inbox emails without logged in to your gmail account.", is_active: true)

  	
  	p "Inserted Successfully.."
  end

end
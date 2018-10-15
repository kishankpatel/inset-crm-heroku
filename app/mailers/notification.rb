require 'open-uri'

class Notification < ActionMailer::Base
  include Icalendar
  include SendGrid
  helper :mailer
  default :from => 'support@insethub.com'
  
  def send_email(to,cc,bcc,subject,msg,temp_files,frommail='InSet CRM <no-reply@insethub.com>',activity_id, name, mailer_id,sender,encrypt_contact,contactable_type,user)
    @mailer_id = mailer_id
    @message  = msg
    @origin_id = activity_id
    @name = name
    @email = to
    @sender = sender
    if temp_files.present?
      temp_files.each do |file|
        attachments[file.attachment_file_name] =  open(file.attachment.url).read #File.read(file.attachment.url) 
      end
    end
    mail(to: to, cc: cc,bcc: bcc, subject: subject, from: sender, reply_to: sender)
  end
  
  def send_deal_info(email,name,created_by,title,deal_id)
    @name=name
    @created_user=created_by
    @deal_title=title
    @deal_id = deal_id
    mail(to: email, subject: "InSet CRM: New deal assigned")
  end
  
  def send_task_info(email,name, created_by, due_date,title,url,type,type_id)
    @name=name
    @created_user=created_by
    @task_due_date=due_date
    @task_title=title
	  @task_url=url
    @associated_obj_type=type
    @associated_obj_type_id=type_id
    mail(to: email, subject: "InSet CRM: New task assigned")
  end
  
  def send_event_info(email, start_date, end_date, title, deal_title, con_email)
    mail(:to => email, :subject => "InSet CRM: Invitation for the event") do |format|
       format.ics {
       ical = Icalendar::Calendar.new
       e = Icalendar::Event.new
       e.dtstart = DateTime.strptime(start_date.to_s, '%s')
       e.dtend = DateTime.strptime(end_date.to_s, '%s')
       e.organizer = email
       #e.uid "MeetingRequest"
       e.attendee= ["mailto:"+email.to_s, "mailto:"+con_email.to_s]
       e.summary = title
       #e.description = "Have a long lunch meeting and decide nothing..."
       e.ip_class    = "PRIVATE"
       ical.add_event(e)
       ical.publish
       #ical.to_ical
       render :text => ical.to_ical, :layout => false
      }
    end
  end

  def mail_notification_to_super_admin_for_accept_invitation user, sup_admin
    @user = user
    @sup_admin = sup_admin
    mail(to: @sup_admin.email, subject: "Invitation Accepted | InSet CRM")
  end

  def mail_notification_to_betauser(email,link)
    @email = email
    @link = link
    mail(to: email, subject: "InSet CRM: Verify email")  
  end  
  
 def mail_to_admin_api(admin_email, source, link,contact_name, contact_email,contact_phone,initial_note,subject)
    @admin_email = admin_email
    @contact_name =  contact_name
    @contact_email = contact_email
    @contact_phone = contact_phone
    @initial_note = initial_note
    #@source = source
    @source = subject
    @link = link
    mail(to: admin_email,  subject: "InSet CRM: Hotlead via "+ subject)  
  
  end  
  
  def bulk_lead_notification assigned_email, name, deals, from=nil
    @email = assigned_email
    @deals = deals
    @name = name
    subject_txt = (from == "reassign" ? "re-assigned" : "assigned")
    mail(to: assigned_email, subject: "InSet CRM: #{name}, #{deals.count} Deals #{subject_txt} to you")  
  end
  
  def notification_today_task user, tasks, date
     @user = user
     @tasks = tasks     
     mail(to: user.email, subject: "InSet CRM: #{user.first_name}, Today's tasks #{date}")
  end
  
  def won_deal_notification(a_email,deals,user_name)
     @deal = deals
     @user = user_name
     mail(to:a_email, subject: "InSet CRM: Cheers a deal has been won")
  end
  
  def assign_priority_deal_notification(a_email,deals,user_name,assigned_to)
     @deal = deals
     @user = user_name
	   crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_token)
	   @encrypted_lead_token = crypt.encrypt_and_sign(@deal.hot_lead_token)
	   @assigned_to = crypt.encrypt_and_sign(assigned_to)
     mail(to:a_email,subject: "InSet CRM: \'#{@deal.title}\' has been assigned to you")  
     #mail(to: "amit.mohanty@andolasoft.co.in", subject: "InSet CRM: \'#{@deal.title}\' has been primarily assigned to you")  
   end   

  def send_invoice_email(email, cc, org, invoice, invoice_item,sub,pd_invoice)
    @email = email
    @org = org
    @invoice = invoice
    @invoice_items = invoice_item
    if sub == ""
      sub = "Invoice from #{@org} Inc."
    end
    attachments.inline["#{@invoice.company_name.gsub(' ','_')}_#{@invoice.invoice_no}.pdf"] = pd_invoice.render_pdf#, :filename => "Invoice #{@invoice.invoice_no}.pdf", :type => "application/pdf", :disposition => "inline"
    mail(to: @email,cc: cc, subject: sub)
  end
  def send_invoice_paid_email(email,cc, org, invoice, invoice_item,pd_invoice)
    @email = email
    @org = org
    @invoice = invoice
    @invoice_items = invoice_item
    attachments.inline["#{@invoice.company_name.gsub(' ','_')}_#{@invoice.invoice_no}.pdf"] = pd_invoice.render_pdf
    mail(to: @email,cc: cc, subject: "We have received your payment towards #{@org}")
  end
  
  def send_feedback_to_user(name,email)
    @name = name
    @email = email
    mail(to: email, subject: "InSet CRM: Thank you for your Feedback")
  end

  def send_feedback_to_support(name,email,company,desc)
    @name = name
    @email = email
    @company = company
    @desc = desc
    mail(to: "support@insethub.com", subject: "InSet CRM: Feedback from user (In app)")
  end

  def send_invoice_cancel_email(email,cc, org, invoice, invoice_item)
    @email = email
    @org = org
    @invoice = invoice
    @invoice_items = invoice_item
    mail(to: @email,cc: cc, subject: "Your Invoice has been cancelled towards #{@org}")
  end
  # Send email to assigned user after a task has been created.
  def send_assigned_email_notification( user, task, created_by)
    @user = user
    @created_by = created_by
    @task = task
    mail(to: user.email, subject: "InSet CRM - You Have A New Task (#{task.title})")
  end
  def send_feedback_to_user(name,email)
    @name = name
    @email = email
    mail(to: email, subject: "InSet CRM: Thank you for your Feedback")

  end
  def send_daily_updates(user_ids, deal)
    @deal = deal
    
    @emails = User.where("id IN (?)",user_ids.split(",")).map(&:email)
    mail(to: @emails, subject: "InSet CRM: Daily Updates Reminder")
  end

  def send_create_form_notification(email_to, cc_email=nil, web_form_name, user_email)
    @web_form_name = web_form_name
    @user_email = user_email
    mail(to: email_to, cc:cc_email.present? ? cc_email : "", subject: "Wakeupsales new lead/contact has been created from your website: #{web_form_name}")
  end
  def send_web_form_thank_you_to_user(full_name, email, org_name)
    @full_name = full_name
    @org_name = org_name
    mail(to: email, subject: "Thanks a ton for getting in touch!")
  end
  def send_assigned_job_notification( users_mail, project_job, created_by)
    @created_by = created_by
    @project_job = project_job
    mail(to: users_mail, subject: "InSet CRM - A new Job has been created (#{@project_job.name})")
  end

  def send_appointment_notification( users_mail, project_job, created_by,start_time,end_time)
    @created_by = created_by
    @project_job = project_job
    @start_time = start_time
    @end_time = end_time
    mail(to: users_mail, subject: "InSet CRM - A new Appointment has been created (#{@project_job.name})")
  end
  def send_assigned_user_job_notification( users_mail, project_job, created_by)
    @created_by = created_by
    @project_job = project_job
    mail(to: project_job.assigned_user.email, subject: "InSet CRM - A job has been assigned to you")
  end
  def send_assigned_job_notification_manager( users_mail, project_job, created_by)
    @created_by = created_by
    @project_job = project_job
    mail(to: project_job.project.project_manager.email, subject: "InSet CRM - A job has been assigned")

  end
  def send_comment_notification( users_mail, project_job, created_by)
    @created_by = created_by
    @project_job = project_job
    mail(to: users_mail, subject: "InSet CRM - A new comment has been created (#{@project_job.name})")
  end
  def send_user_verified_mail(email)
    @email = email
    mail(to: email, subject: "InSet CRM | User verified successfully")
  end
  def mail_notification_to_support user, geo_code
    @user = user
    @geo_code = geo_code.first.data if geo_code.present? && geo_code.first.present?
    provider = user.provider
    @sign_up_mode = "Normal"
    mail(to: "matthew.brennan@adaptivedigitaldesign.com", subject: "Inset CRM Cloud: New User SignUp")
  end
end
namespace :wus do  
  #Insert organization trial period
  task :add_org_trial_period => :environment do
  	trial_logger ||= Logger.new("#{Rails.root}/log/add_trial_period.log")
    trial_logger.info("-------- starts at ---"+ Time.now.to_s + "--------")
    Organization.all.each do |org|
        begin
          Notification.send_trial_period_notification_to_org_superadmin(org).deliver
        	puts "Successfully sent trial period email notification to Organization with name:" + org.name
        	trial_logger.info("Successfully sent trial period email notification to Organization with name:" + org.name)
        rescue
        	puts "Unable to send email notification" + org.name
        	trial_logger.info("Unable to send email notification for Organization with name:" + org.name)
        end
        puts "<<<<<<<<< Successfully added trial period for Organization with name: #{org.name} and ID: #{org.id} >>>>>>>>>>"
        trial_logger.info("<<<<<<<<< Successfully added trial period for Organization with name: #{org.name} and ID: #{org.id} >>>>>>>>>>")
    end
  end
end
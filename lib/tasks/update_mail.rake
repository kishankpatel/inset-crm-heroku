namespace :wus do  
  
  #send product update to contacts
  task :send_product_update => :environment do
    IndividualContact.all.each do |ic|
        FeaturesMailer.send_product_update(ic.email,"New in WakeUpSales: Integrated Sales Automation, Google Calendar Synchronization, etc.").deliver 
    end
  end

end
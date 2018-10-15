namespace :wus do  
  
  #Insert organization types
  task :insert_org_type => :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE organization_types")
    org_types = ["Software, App Development", "Health", "Tech Startup", "Education and Training", "Real Estate", "Creative Agency (Web, Advertising, Video)", "Financial or Credit Services", "News, Media and Publications", "Manufacturing", "IT Services", "Consulting", "Construction", "Trade (Retail, Wholesale)", "Other"]
    org_types.each do |org_type|
        OrganizationType.create(name: org_type)
        puts "<<<<<<<<< Successfully created Orgazation Type with name:#{org_type}>>>>>>>>>>"
    end
  end
end
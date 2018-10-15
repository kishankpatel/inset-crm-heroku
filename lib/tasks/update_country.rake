namespace :country do  
	 task :update_priority => :environment do 
	 	priority_countries = ["Brazil", "India"]
	 	priority_countries.each do | con|
	 		country = Country.find_by_name(con).update_attribute("is_priority", true)
	 	end
	 end
end
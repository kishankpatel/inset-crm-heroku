namespace :wus do
  task :insert_user_label => :environment do 
    Organization.all.each do |org|    	
	    
	    org_inbound = org.user_labels.where("name=?", "Inbound").first
		unless org_inbound.present?
		  org.user_labels.create(name: "Inbound")
		end

		org_outbound = org.user_labels.where("name=?", "Outbound").first
		unless org_outbound.present?
		  org.user_labels.create(name: "Outbound")
		end

		org_uncategorised = org.user_labels.where("name=?", "Uncategorised").first
		unless org_uncategorised.present?
		  org.user_labels.create(name: "Uncategorised")
		end

        p "User label insrted successfully on org: #{org.id}"
    end
  end
end
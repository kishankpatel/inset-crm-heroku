namespace :wus do  
  #Update user labels
  task :update_user_labels => :environment do
    Organization.all.each do |org|
      inbound_deals = org.deals.where("user_label_id = ?", 2)
      inbound_deals.update_all :user_label_id => org.user_labels.where("name =?", "Inbound").first.id

      outbound_deals = org.deals.where("user_label_id = ?", 3)
      outbound_deals.update_all :user_label_id => org.user_labels.where("name =?", "Outbound").first.id

      uncategorised_deals = org.deals.where("user_label_id = ? OR user_label_id IS NULL", 1)
      uncategorised_deals.update_all :user_label_id => org.user_labels.where("name =?", "Uncategorised").first.id
      puts "Deal user labels updated : #{org.id}-#{org.name}"
    end
  end
end
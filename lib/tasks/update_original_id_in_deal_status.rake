namespace :wus do
  task :update_original_id_in_deal_status => :environment do
    Organization.all.each do |org|
      org.deal_statuses.where("original_id !=? AND name=?", 1, "New").each do |deal_statuse|
        case deal_statuse.name
        when "New"
          deal_statuse.update_attributes :original_id=> 1
        when "Qualified"
          deal_statuse.update_attributes :original_id=> 2
        when "Not Qualified"
          deal_statuse.update_attributes :original_id=> 3
        when "Quote"
          deal_statuse.update_attributes :original_id=> 4
        when "Won"
          deal_statuse.update_attributes :original_id=> 5
        when "Lost"
          deal_statuse.update_attributes :original_id=> 6
        end
      end
    end
  end
end
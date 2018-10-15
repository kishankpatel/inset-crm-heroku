class AddColumnsToCompanyContact < ActiveRecord::Migration
  def change
    add_column :company_contacts, :total_opportunities, :integer, :default => 0
    add_column :company_contacts, :total_open_opportunities, :integer, :default => 0
    Organization.all.each do |org|
    	org.company_contacts.each do |company|
	   		total_deals=company.individual_contacts.map{|i|i.deals_contacts.includes(:deal).map(&:deal)}.flatten
	   		deals_count=total_deals.select{|d| d.is_active if d}.count
	   		open_deals_count=total_deals.select{|d| (d.is_won == nil || d.is_won == "") && d.is_active if d}.count
	   		company.update_column(:total_opportunities, deals_count)
	   		company.update_column(:total_open_opportunities, open_deals_count)
	   end
	end
  end
end

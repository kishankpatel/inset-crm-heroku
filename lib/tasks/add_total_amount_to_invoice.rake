namespace :wus do  
  
  #Insert total amount to Invoice from its invoice items
  task :add_total_amount_to_invoice => :environment do
    Organization.all.each do |org|
    	if org.invoices.present?
    		org.invoices.each do |invoice|
    			total_amount=invoice.invoice_items.inject(0){|sum,x| sum + x.amount.to_f }
          if total_amount.present? && invoice.tax.present?
            tax_on_total=(total_amount/100) * invoice.tax
            sum = "%.2f" % (total_amount+tax_on_total)
          elsif total_amount.present? && !invoice.tax.present?
            sum = "%.2f" % total_amount
          else
            sum = 0
          end
          invoice.update_attributes total_amount: sum
          p "Total Invoice amount:#{sum}"
    		end
    	end 
    end
  end
end
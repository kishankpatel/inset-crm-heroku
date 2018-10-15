# == Schema Information
#
# Table name: plugin_transactions
#
#  id                  :integer          not null, primary key
#  community_plugin_id :integer
#  name                :string(255)
#  email               :string(255)
#  phone               :string(255)
#  gmt_offset          :string(255)
#  location            :string(255)
#  ip                  :string(255)
#  referrer            :text
#  transaction_id      :text
#  transaction_status  :string(255)
#  invoice_id          :integer
#  is_emailed          :boolean
#  token               :text
#  download_date       :datetime
#  latitude            :float
#  longitude           :float
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  download_count      :integer          default(0)
#

class PluginTransaction < ActiveRecord::Base
  belongs_to :community_plugin
  attr_accessible :community_plugin_id, :download_date, :download_count, :email, :gmt_offset, :invoice_id, :ip, :is_emailed, :latitude, :location, :longitude, :name, :phone, :referrer, :token, :transaction_id, :transaction_status

  	after_create :update_data, :send_invoice_mail

  	def update_data
	  self.update_column(:transaction_id, Digest::MD5.hexdigest(self.id.to_s+self.community_plugin_id.to_s+Time.now.to_s))
	  self.update_column(:token, Digest::MD5.hexdigest(self.id.to_s+self.transaction_id.to_s+Time.now.to_s))
	end

	def send_invoice_mail
		Payday::Config.default.invoice_logo = "public/image/wus-all-in-one.png"
		Payday::Config.default.company_name = "Andolasoft"
		Payday::Config.default.company_details = "2059 Camden Ave. #118\nSan Jose, CA - 95124, USA"
		#@invoice = Invoice.create(user_id: current_user.id, contact_id: @contact_id, contact_type: params[:invoice][:contact_type], currency: params[:invoice][:currency], invoice_no: params[:invoice][:invoice_no], due_date: params[:invoice][:due_date], cc_mail_id: params[:invoice][:cc_mail_id], status: "Send", notes: params[:invoice][:notes], terms_and_condition: params[:invoice][:terms_and_condition], transaction_date: Time.new, organization_id: @current_organization.id)
		#if @invoice
			#@invoice_item = InvoiceItem.create(description: params[:description], amount: params[:amount], invoice_id: @invoice.id)
			pd_invoice = Payday::Invoice.new(:invoice_number => self.invoice_id, :bill_to => self.name + "\n" + self.email, :notes => 'This charge will appear on your credit card statement as "ANDOLASOFT INC".', :paid_at => self.created_at.strftime("%b %d, %Y"))
			pd_invoice.line_items << Payday::LineItem.new(:price => self.community_plugin.price, :quantity => 1, :description => self.community_plugin.description)
		#end
		#Notification.send_invoice_email(@contact.email,params[:invoice][:cc_mail_id], @current_organization.name, @invoice,@invoice_item,"",pd_invoice).deliver
		if self.community_plugin.is_plugin
			Notification.plugin_payment_success(self, self.invoice_id, self.token,pd_invoice).deliver
		else
        	Notification.installation_support(self, self.invoice_id, self.token,pd_invoice).deliver
        end 
		# Notification.admin_plugin_payment_notification(self.name, self.email, self.community_plugin.name, self.gmt_offset).deliver
	end
end

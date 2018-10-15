# == Schema Information
#
# Table name: self_hosting_users
#
#  id                   :integer          not null, primary key
#  license_type         :string(255)
#  license_key          :text
#  user_limit           :integer
#  installation_support :boolean          default(FALSE)
#  name                 :string(255)
#  email                :string(255)
#  phone                :string(255)
#  gmt_offset           :string(255)
#  location             :string(255)
#  ip                   :string(255)
#  referrer             :text
#  transaction_id       :text
#  transaction_status   :string(255)
#  invoice_id           :integer
#  is_emailed           :boolean
#  token                :text
#  download_date        :datetime
#  latitude             :float
#  longitude            :float
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  amount               :integer
#  customer_id          :integer
#  total_users          :integer          default(0)
#

require 'securerandom'
require 'validate_license'
class SelfHostingUser < ActiveRecord::Base
  attr_accessible :download_date, :email, :gmt_offset, :installation_support, :invoice_id, :ip, :is_emailed, :latitude, :license_key, :license_type, :location, :longitude, :name, :phone, :referrer, :token, :transaction_id, :transaction_status, :user_limit, :amount, :customer_id, :total_users, :unique_key, :download_count
  after_create :create_customer_id, :update_data, :send_invoice_mail
 	

 	def self.listing
    	select("id, name, email, installation_support, created_at, invoice_id, license_key, license_type, location, token, transaction_id, transaction_status, user_limit, amount, customer_id, download_count").order("created_at desc")
  	end

  	def update_data
	  generate_lincense_key = ValidateLicense.new("2136b3f5ec6dcaddb637e9c9654aa879", "s_#{self.user_limit}_#{(self.created_at+1.year).strftime("%d-%b-%Y")}_#{self.customer_id}")
	  self.update_column(:unique_key, SecureRandom.hex(5))
	  self.update_attributes(:token => Digest::MD5.hexdigest(self.id.to_s+self.transaction_id.to_s+Time.now.to_s), :license_type => "server", :license_key => generate_lincense_key.encrypt)
	end

	def send_invoice_mail
		Payday::Config.default.invoice_logo = "public/image/wus-all-in-one.png"
		Payday::Config.default.company_name = "Andolasoft"
		Payday::Config.default.company_details = "2059 Camden Ave. #118\nSan Jose, CA - 95124, USA"
		
		pd_invoice = Payday::Invoice.new(:invoice_number => self.invoice_id, :bill_to => self.name + "\n" + self.email, :notes => 'This charge will appear on your credit card statement as "ANDOLASOFT INC".', :paid_at => self.created_at.strftime("%b %d, %Y"))
		pd_invoice.line_items << Payday::LineItem.new(:price => self.installation_support ? (self.amount - 99) : self.amount, :quantity => 1, :description => "Wakeupsales self hosting")
		if self.installation_support
			pd_invoice.line_items << Payday::LineItem.new(:price => 99, :quantity => 1, :description => "Wakeupsales self hosting installation support")
		end
        Notification.self_hosting_payment_success(self, self.invoice_id, self.token,pd_invoice).deliver
        # Notification.self_hosting_payment_success(self, self.invoice_id, self.token,pd_invoice, "mail_to_support").deliver
	end

	#unique Customer ID is generated

	def create_customer_id
		self.update_column(:customer_id, generate_customer_id)
	end

	def generate_customer_id
		self.customer_id = loop do
	      random_id = SecureRandom.random_number(10**5)
	      break random_id unless SelfHostingUser.exists?(customer_id: random_id)
	    end
	end  
end

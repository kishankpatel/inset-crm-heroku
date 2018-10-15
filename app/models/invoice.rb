# == Schema Information
#
# Table name: invoices
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  contact_id          :integer
#  contact_type        :string(255)
#  currency            :string(255)
#  invoice_no          :string(255)
#  due_date            :date
#  cc_mail_id          :string(255)
#  status              :string(255)
#  notes               :text
#  terms_and_condition :text
#  transaction_date    :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organization_id     :integer
#  logo_url            :string(255)
#  deal_id             :integer
#  company_name        :string(255)
#  company_address     :text
#  tax                 :float
#  is_sent             :boolean          default(TRUE)
#  total_amount        :string(255)      default("0")
#  discount            :float
#  po_number           :string(255)
#  start_date          :date
#  end_date            :date
#  billable_hours      :integer
#  project_id          :integer
#  invoice_type        :string(255)      default("invoice")
#  is_active           :boolean          default(TRUE)
#

class Invoice < ActiveRecord::Base  
  attr_accessible :cc_mail_id, :contact_id, :contact_type, 
                  :currency, :due_date, :invoice_no, :notes, 
                  :status, :terms_and_condition, :transaction_date, 
                  :user_id, :organization_id, :deal_id, :logo_url, 
                  :company_name, :company_address, :tax, 
                  :invoice_items_attributes, :invoice_items, 
                  :is_sent, :total_amount, :discount, :po_number,
                  :project_id, :start_date, :end_date, 
                  :invoice_type, :is_active
                  
  has_one :image, :as => :imagable, :dependent => :destroy
  has_many :invoice_items
  belongs_to :user
  belongs_to :organization
  belongs_to :deal
  belongs_to :contact
  belongs_to :individual_contact, :foreign_key=>"contact_id"
  belongs_to :project, :foreign_key=>"project_id"
  accepts_nested_attributes_for :invoice_items, reject_if: proc { |attributes| attributes['qty'].blank? && attributes['rate'].blank? }, :allow_destroy => true
end

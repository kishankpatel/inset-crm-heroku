# == Schema Information
#
# Table name: invoice_items
#
#  id              :integer          not null, primary key
#  description     :text
#  amount          :string(255)
#  invoice_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  qty             :integer
#  rate            :float
#  job_time_log_id :integer
#

class InvoiceItem < ActiveRecord::Base
  attr_accessible :amount, :description, :invoice_id, :qty, :rate,:job_time_log_id
  belongs_to :invoice
end

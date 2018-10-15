# == Schema Information
#
# Table name: payment_infos
#
#  id               :integer          not null, primary key
#  organization_id  :integer
#  transaction_id   :string(255)
#  amount           :float
#  transaction_date :datetime
#  last4_digit      :string(255)
#  customer_id      :string(255)
#  card_holder_name :string(255)
#  street           :string(255)
#  city             :string(255)
#  country          :string(255)
#  zipcode          :string(255)
#  payment_token    :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class PaymentInfo < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :amount, :card_holder_name, :city, :country, :customer_id, :last4_digit, :payment_token, :street, :transaction_date, :transaction_id, :zipcode
end

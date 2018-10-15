# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  organization_id  :integer
#  address_type     :string(255)
#  address          :text
#  country_id       :integer
#  state            :string(255)
#  city             :string(255)
#  zipcode          :string(255)
#  addressable_type :string(255)
#  addressable_id   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Address < ActiveRecord::Base
  belongs_to :organization
  belongs_to :country ,:foreign_key=>"country_id"
  belongs_to :addressable , :polymorphic=> true
  
  
  attr_accessible :address, :address_type, :addressable_id, :addressable_type, :organization_id, :city, :state, :zipcode,:country_id,:organization, :addressable
end

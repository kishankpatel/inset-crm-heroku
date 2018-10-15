# == Schema Information
#
# Table name: phones
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  phone_no        :string(255)
#  extension       :string(255)
#  phone_type      :string(255)
#  phoneble_type   :string(255)
#  phoneble_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Phone < ActiveRecord::Base
  belongs_to :organization
  belongs_to :phoneble , :polymorphic=> true
  attr_accessible :extension, :phone_no, :phone_type, :phoneble_id, :phoneble_type,
    :organization,:organization_id, :phoneble
  
  
  scope :by_phone_type, lambda{|type| where("phone_type = ? ", type)}
  
  
end

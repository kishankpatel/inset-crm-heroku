# == Schema Information
#
# Table name: contact_opportunities
#
#  id                    :integer          not null, primary key
#  opportunity           :string(255)
#  individual_contact_id :integer
#  deal_id               :integer
#  is_converted          :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class ContactOpportunity < ActiveRecord::Base
  belongs_to :deal, :dependent => :destroy
  attr_accessible :deal_id, :individual_contact_id, :is_converted, :opportunity
end

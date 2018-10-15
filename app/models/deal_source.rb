# == Schema Information
#
# Table name: deal_sources
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  deal_id         :integer
#  source_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class DealSource < ActiveRecord::Base
  belongs_to :organization
  belongs_to :deal
  belongs_to :source
   attr_accessible :organization,:deal,:source,:source_id,:deal_id
end

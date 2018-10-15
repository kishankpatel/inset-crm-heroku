# == Schema Information
#
# Table name: lost_reasons
#
#  id              :integer          not null, primary key
#  reason          :text
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class LostReason < ActiveRecord::Base
  attr_accessible :organization_id, :reason
  belongs_to :organization
end

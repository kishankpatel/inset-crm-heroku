# == Schema Information
#
# Table name: user_designations
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class UserDesignation < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :organization_id
end

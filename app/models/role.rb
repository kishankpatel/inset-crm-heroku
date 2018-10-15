# == Schema Information
#
# Table name: roles
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Role < ActiveRecord::Base

  belongs_to :organization
  attr_accessible :name,:organization,:organization_id
end

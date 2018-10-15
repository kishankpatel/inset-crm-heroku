# == Schema Information
#
# Table name: organization_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OrganizationType < ActiveRecord::Base
  attr_accessible :name
end

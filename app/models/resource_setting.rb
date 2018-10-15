# == Schema Information
#
# Table name: resource_settings
#
#  id              :integer          not null, primary key
#  hours_of_work   :integer
#  week_off_days   :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#

class ResourceSetting < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :hours_of_work, :week_off_days,:organization_id
  serialize :week_off_days
end

# == Schema Information
#
# Table name: user_roles
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  role_id         :integer
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class UserRole < ActiveRecord::Base
  belongs_to :organization
  belongs_to :role
  belongs_to :user
  attr_accessible :role_id, :organization_id
end

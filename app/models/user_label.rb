# == Schema Information
#
# Table name: user_labels
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  user_id         :integer
#  name            :string(255)
#  color           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class UserLabel < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  has_many :deal_labels, :dependent => :destroy
  attr_accessible :color, :name,:organization,:user
end

# == Schema Information
#
# Table name: user_plugins
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  plugin_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserPlugin < ActiveRecord::Base
  attr_accessible :user_id, :plugin_id
  belongs_to :user
  belongs_to :plugin
end

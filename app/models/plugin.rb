# == Schema Information
#
# Table name: plugins
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :text
#  is_active   :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Plugin < ActiveRecord::Base
  attr_accessible :description, :is_active, :title
  has_many :user_plugins
  has_many :users, :through => :user_plugins
end

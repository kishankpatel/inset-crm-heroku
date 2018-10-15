# == Schema Information
#
# Table name: community_plugins
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  price       :integer
#  description :text
#  unique_id   :text
#  is_active   :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  is_plugin   :boolean          default(TRUE)
#

class CommunityPlugin < ActiveRecord::Base
  has_many :plugin_transactions
  attr_accessible :description, :is_active, :name, :price, :unique_id, :is_plugin

  after_create :set_unique_id
  
  #unique ID is generated to access the checkout page
  #from outside
  def set_unique_id
    self.update_column(:unique_id, Digest::MD5.hexdigest(self.id.to_s+Time.now.to_s))
  end
end

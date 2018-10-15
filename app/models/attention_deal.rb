# == Schema Information
#
# Table name: attention_deals
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  user_id         :integer
#  deal_ids        :text
#  deal_count      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AttentionDeal < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  attr_accessible :organization_id, :user_id, :deal_ids, :deal_count
  serialize :deal_ids
end

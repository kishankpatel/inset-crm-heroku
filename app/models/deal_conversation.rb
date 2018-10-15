# == Schema Information
#
# Table name: deal_conversations
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  deal_id         :integer          not null
#  organization_id :integer          not null
#  message         :text
#  subject         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class DealConversation < ActiveRecord::Base
  attr_accessible :message, :subject,  :deal_id, :user_id, :organization_id

  belongs_to :user
  belongs_to :deal
  belongs_to :organization
  has_many :deal_attachments
end

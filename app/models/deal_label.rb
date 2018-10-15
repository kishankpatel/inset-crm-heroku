# == Schema Information
#
# Table name: deal_labels
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  deal_id         :integer
#  user_label_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class DealLabel < ActiveRecord::Base
  belongs_to :organization
  belongs_to :deal
  belongs_to :user_label
  # attr_accessible :title, :body
  attr_accessible :deal_id,:user_label_id,:organization
end

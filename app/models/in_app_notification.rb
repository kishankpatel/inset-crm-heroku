# == Schema Information
#
# Table name: in_app_notifications
#
#  id                    :integer          not null, primary key
#  organization_id       :integer
#  user_id               :integer
#  activity_type         :string(255)
#  notificationable_type :string(255)
#  notificationable_id   :integer
#  message               :string(255)
#  is_read               :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class InAppNotification < ActiveRecord::Base
  belongs_to :notificationable , :polymorphic=> true
  belongs_to :organization
  belongs_to :user
  attr_accessible :notificationable_id, :notificationable_type, :organization_id, :user_id, :activity_type, :is_read, :message, :notificationable, :organization, :user
end

class ExpiryNotification < ActiveRecord::Base
  attr_accessible :email, :expiry_end_notification, :is_extended, :organization_id, :trial_expires_on
  belongs_to :organization
end

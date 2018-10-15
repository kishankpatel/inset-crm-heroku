class Subscription < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :free_trial_days, :is_active, :plan_id, :price, :storage_limit, :user_limit
end

class Feedback < ActiveRecord::Base
  attr_accessible :message, :organization_id, :rating, :user_id
  belongs_to :organization
  belongs_to :user
end

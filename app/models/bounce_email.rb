# == Schema Information
#
# Table name: bounce_emails
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  sender_email    :string(255)
#  recipient_email :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  subject         :string(255)
#  json_response   :text
#

class BounceEmail < ActiveRecord::Base
  attr_accessible :organization_id, :recipient_email, :sender_email, :subject, :json_response
  belongs_to :organization
end

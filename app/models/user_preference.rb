# == Schema Information
#
# Table name: user_preferences
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  organization_id       :integer
#  weekly_digest         :boolean          default(TRUE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  digest_mail_frequency :string(255)      default("weekly")
#

class UserPreference < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  attr_accessible :digest_mail_frequency, :weekly_digest, :organization_id, :user
end

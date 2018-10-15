# == Schema Information
#
# Table name: api_integrations
#
#  id                 :integer          not null, primary key
#  organization_id    :integer
#  url                :string(255)
#  api_name           :string(255)
#  account_id         :string(255)
#  auth_token         :string(255)
#  oauth_access_token :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ApiIntegration < ActiveRecord::Base
  attr_accessible :organization_id, :api_name, :account_id, :auth_token, :oauth_access_token, :url
  belongs_to :organization

  validates_presence_of :api_name, :account_id, :auth_token, :organization
  validates_presence_of :url, if: :is_zendesk_api?

  private

  def is_zendesk_api?
    self.api_name.downcase == 'zendesk'
  end
end

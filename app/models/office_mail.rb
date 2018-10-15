# == Schema Information
#
# Table name: office_mails
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  user_id         :integer
#  office_mail     :string(255)
#  token_hash      :text
#  token           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class OfficeMail < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  serialize :token_hash
  attr_accessible :office_mail, :token, :token_hash,:user_id, :organization_id
end

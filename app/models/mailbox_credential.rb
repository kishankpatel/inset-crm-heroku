# == Schema Information
#
# Table name: mailbox_credentials
#
#  id            :integer          not null, primary key
#  client_id     :string(255)
#  client_secret :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class MailboxCredential < ActiveRecord::Base
  attr_accessible :client_id, :client_secret
end

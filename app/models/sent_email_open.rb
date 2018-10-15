# == Schema Information
#
# Table name: sent_email_opens
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  email       :string(255)
#  ip_address  :string(255)
#  opened      :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  obj_id      :integer
#  obj_type    :string(255)
#  activity_id :integer
#

class SentEmailOpen < ActiveRecord::Base
  attr_accessible :email, :ip_address, :activity_id, :name, :opened
end

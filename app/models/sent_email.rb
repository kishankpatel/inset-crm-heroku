# == Schema Information
#
# Table name: sent_emails
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  sent       :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  obj_id     :integer
#  obj_type   :string(255)
#

class SentEmail < ActiveRecord::Base
  attr_accessible :name, :email, :sent
end

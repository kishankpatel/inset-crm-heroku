# == Schema Information
#
# Table name: contact_us
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  is_remote  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ContactUs < ActiveRecord::Base
  attr_accessible :email, :is_remote
end

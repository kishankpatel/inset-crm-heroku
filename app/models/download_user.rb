# == Schema Information
#
# Table name: download_users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  ip_address :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DownloadUser < ActiveRecord::Base
  attr_accessible :email, :ip_address, :name
end

# == Schema Information
#
# Table name: spam_emails
#
#  id                :integer          not null, primary key
#  email             :string(255)
#  nickname          :string(255)
#  organization_name :string(255)
#  region_name       :string(255)
#  city              :string(255)
#  country_name      :string(255)
#  latitude          :string(255)
#  longitude         :string(255)
#  ip                :string(255)
#  time_zone         :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SpamEmail < ActiveRecord::Base
  attr_accessible :email, :nickname, :organization_name, :region_name, :city, :country_name, :latitude, :longitude, :ip, :time_zone
end

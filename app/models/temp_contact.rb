# == Schema Information
#
# Table name: temp_contacts
#
#  id              :integer          not null, primary key
#  import_by       :integer
#  domain          :string(255)
#  email           :string(255)
#  first_name      :string(255)
#  last_name       :string(255)
#  name            :string(255)
#  gender          :string(255)
#  birthday        :string(255)
#  relation        :string(255)
#  address_1       :string(255)
#  address_2       :string(255)
#  city            :string(255)
#  region          :string(255)
#  country         :string(255)
#  postcode        :string(255)
#  phone_number    :string(255)
#  profile_picture :string(255)
#  updated         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TempContact < ActiveRecord::Base
  attr_accessible :import_by,:domain,:email,  :first_name, :last_name, :name, :birthday, :city, :country,  :gender,:address_1, :address_2, :phone_number, :postcode, :profile_picture, :region, :relation, :updated
end

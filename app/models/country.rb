# == Schema Information
#
# Table name: countries
#
#  id          :integer          not null, primary key
#  ccode       :string(255)
#  name        :string(255)
#  isd_code    :string(255)
#  flag        :string(255)
#  is_priority :boolean          default(FALSE)
#

class Country < ActiveRecord::Base
  attr_accessible :name,:ccode,:isd_code,:flag
  
  
  
end

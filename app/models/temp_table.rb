# == Schema Information
#
# Table name: temp_tables
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  email        :string(255)
#  phone        :string(255)
#  title        :string(255)
#  company_name :string(255)
#  web_site     :string(255)
#  address      :text
#  ref_site     :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  city         :string(255)
#  state        :string(255)
#  zipcode      :string(255)
#  country      :string(255)
#  user_id      :integer
#  note         :text
#  first_name   :string(255)
#  last_name    :string(255)
#

class TempTable < ActiveRecord::Base
  attr_accessible :address, :company_name, :email, :name, :phone, :ref_site, :title, :web_site, :city, :state, :zipcode, :country, :user_id, :note,:first_name,:last_name
end

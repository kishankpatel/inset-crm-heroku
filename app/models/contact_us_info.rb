# == Schema Information
#
# Table name: contact_us_infos
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  comment       :text
#  phone         :string(255)
#  contact_us_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  need_help     :string(255)
#

class ContactUsInfo < ActiveRecord::Base
  belongs_to :contact_us
  attr_accessible :comment, :name, :phone, :contact_us, :need_help
end

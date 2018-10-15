# == Schema Information
#
# Table name: company_strengths
#
#  id         :integer          not null, primary key
#  range      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CompanyStrength < ActiveRecord::Base
  attr_accessible :range
end

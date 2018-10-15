# == Schema Information
#
# Table name: company_industries
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  industry_code :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CompanyIndustry < ActiveRecord::Base
  attr_accessible :industry_code, :name
  has_many :organization_industries
end

# == Schema Information
#
# Table name: organization_industries
#
#  id                  :integer          not null, primary key
#  organization_id     :integer
#  company_industry_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class OrganizationIndustry < ActiveRecord::Base
  belongs_to :organization
  belongs_to :company_industry
  # attr_accessible :title, :body
end

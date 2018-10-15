# == Schema Information
#
# Table name: secondary_companies
#
#  id                    :integer          not null, primary key
#  organization_id       :integer
#  individual_contact_id :integer
#  company_contact_id    :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class SecondaryCompany < ActiveRecord::Base
  belongs_to :organization
  belongs_to :individual_contact
  belongs_to :company_contact
  attr_accessible :organization_id, :individual_contact_id,:company_contact_id
  def self.create_or_skip organization_id,company_contact_id,individual_contact_id
    sc = SecondaryCompany.where(:organization_id=>organization_id,company_contact_id: company_contact_id,individual_contact_id: individual_contact_id).first
    if(!sc.present?)
      puts " SecondaryCompany not found................ so creating new"
      SecondaryCompany.create(:organization_id=>organization_id,company_contact_id: company_contact_id,individual_contact_id: individual_contact_id)
    end
  end
end

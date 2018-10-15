# == Schema Information
#
# Table name: industries
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Industry < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name,:organization,:organization_id
  has_many :deal_industries,:dependent => :destroy
  
  validates :name, :uniqueness => {:scope => :organization_id}
  
  def self.industry_list(organization)
    select("id, name, organization_id").where("organization_id=?", organization)
  end

  def self.get_name(source_id)
    select("name").where("id=?", source_id).first.name
  end
end

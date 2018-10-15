# == Schema Information
#
# Table name: deal_statuses
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  original_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  is_active       :boolean          default(TRUE), not null
#  is_visible      :boolean          default(TRUE)
#  color           :string(255)
#  is_funnel_view  :boolean          default(TRUE)
#  is_kanban       :boolean          default(FALSE)
#

class DealStatus < ActiveRecord::Base
  belongs_to :organization
  has_many :deals
  attr_accessible :name, :original_id, :organization_id, :is_active, :is_visible, :color, :is_funnel_view, :is_kanban
  before_destroy :check_if_deals_present?
  
  
  #to get the priority name as per organization
  def self.get_deal_name deal_original_id, org
#    self.find_by_original_id_and_organization_id deal_original_id, org
    select("id, original_id, organization_id, name, is_active, is_visible").where("id=? AND organization_id=?", deal_original_id, org).first
  end
  
  #to update the priority name as per organization
  def self.update_status deal, qualify, not_qualify, won, lost, junk, org
   priority = {"1" => deal, "2" => qualify, "3" => not_qualify, "4" => won, "5" => lost, "6" => junk}   
   priority.each_pair do |key, value|    
     self.get_deal_name(key,org).update_attribute(:name,value)
   end 
  end
  def is_incoming?
    return self.original_id == "1" ? true  : false
  end
  def is_qualified?
    return self.original_id == "2" ? true  : false
  end
  def is_not_qualified?
    return self.original_id == "3" ? true  : false
  end
  def is_won?
    return self.original_id == "4" ? true  : false
  end
  def is_lost?
    return self.original_id == "5" ? true  : false
  end
  def is_junk?
    return self.original_id == "6" ? true  : false
  end
  private
  def check_if_deals_present?
    puts "coming to check before destroy ............................"
    return true if self.deals.count == 0
    errors.add :base, "Cannot delete deal status.Deals exists for this!!"
    false
  end
end

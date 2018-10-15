# == Schema Information
#
# Table name: deals_contacts
#
#  id               :integer          not null, primary key
#  organization_id  :integer
#  deal_id          :integer
#  contactable_type :string(255)
#  contactable_id   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class DealsContact < ActiveRecord::Base
   attr_accessible :organization_id, :deal_id, :contactable_type, :contactable_id, :created_at, :updated_at,:contactable
   belongs_to :contactable , :polymorphic=> true
   belongs_to :deal
   
   after_create :insert_activty_for_deal
   def insert_activty_for_deal

   if self.deal.is_remote? 
	  curuser=User.find_by_id(self.deal.initiated_by)
	 else
	  curuser= User.current
	 end
     Activity.create(:organization_id => self.organization_id,	:activity_user_id => curuser.present? ? curuser.id : self.deal.initiated_by, :activity_type=> self.class.name, :activity_id => self.id, :activity_status => "Add",:activity_desc=>self.contactable.full_name,:activity_date => self.created_at, :is_public => true, :source_id => self.deal_id,:source_type => self.deal.class.name)
   end
end

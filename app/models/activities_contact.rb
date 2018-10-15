# == Schema Information
#
# Table name: activities_contacts
#
#  id               :integer          not null, primary key
#  organization_id  :integer
#  activity_id      :integer
#  contactable_type :string(255)
#  contactable_id   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ActivitiesContact < ActiveRecord::Base
   attr_accessible :organization_id, :activity_id, :contactable, :contactable_type, :contactable_id
   
   belongs_to :contactable , :polymorphic=> true
   belongs_to :activity, :foreign_key=>"activity_id"
   
end

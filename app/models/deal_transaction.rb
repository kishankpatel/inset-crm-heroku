# == Schema Information
#
# Table name: deal_transactions
#
#  id                  :integer          not null, primary key
#  organization_id     :integer
#  deal_id             :integer
#  deal_status_id      :integer
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  assigned_to         :integer
#  is_activity_display :boolean          default(TRUE)
#

class DealTransaction < ActiveRecord::Base
  attr_accessible :deal_id, :deal_status_id, :organization_id, :user_id,:user, :is_activity_display, :assigned_to
  belongs_to :deal
  belongs_to :deal_status
  belongs_to :organization
  belongs_to :user
  after_create :insert_deal_move_activity, :get_goals
  
  def insert_deal_move_activity
    Activity.create(:organization_id => self.organization_id,  :activity_user_id => User.current.present? ? User.current.id : (admin_user=(self.organization.users.where("admin_type=?", 1)).present? ? admin_user.first.id : ""),:activity_type=> "DealTransaction", :activity_id => self.id, :activity_status => "Move",:activity_desc=>self.deal.title,:activity_date => self.updated_at, :is_public => (self.deal.is_public.nil? ||  self.deal.is_public.blank?) ? false : self.deal.is_public, :source_id => self.deal.id,:source_type => self.deal.class.name)
  end
  
  def get_goals
    if self.user_id.present?
       @user = User.find self.user_id        
       if @user.goals.present?
          @user.goals.each do |gl|
            if gl.goal_type == 'quantity of deals'
              if gl.deal_stage_id == self.deal_status_id
                UserGoal.create(:user_id=>self.user_id,:goal_id => gl.id,:deal_id => self.deal_id)
              end
            elsif gl.goal_type == 'value of deals'
              if gl.deal_stage_id == self.deal_status_id
                @deal = Deal.find self.deal_id
                UserGoal.create(:user_id=>self.user_id,:goal_id => gl.id,:deal_id => self.deal_id,:amount => @deal.amount)
              end
            elsif gl.goal_type == 'quantity of deals won'
              @deal = Deal.find self.deal_id
              #UserGoal.create(:user_id=>self.user_id,:goal_id => gl.id,:deal_id => self.deal_id)
            else    
              #if gl.deal_stage_id == self.deal_status_id
                @deal = Deal.find self.deal_id
                #UserGoal.create(:user_id=>self.user_id,:goal_id => gl.id,:deal_id => self.deal_id,:amount=> @deal.amount)
              #end      
            end
          end
       end
      end
  end
end

# == Schema Information
#
# Table name: daily_updates
#
#  id         :integer          not null, primary key
#  deal_id    :integer
#  user_ids   :string(255)
#  alert_time :time
#  time_zone  :string(255)
#  frequency  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DailyUpdate < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user, :foreign_key => "created_by"
  attr_accessible :alert_time, :frequency, :time_zone, :user_ids, :deal_id, :created_by, :last_reminder_sent_at, :recipient_ids, :organization_id
  after_create :send_daily_update_mail
  
  def send_daily_update_mail
  	begin
  		puts "3333333333333333333"
  		Notification.send_daily_updates(self.user_ids,self.deal, self.user, self.recipient_ids).deliver
  	rescue Exception => e
  		puts "-------- error to send mail #{e.message}"
  	end
  end
end

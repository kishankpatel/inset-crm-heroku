# == Schema Information
#
# Table name: reminders
#
#  id                :integer          not null, primary key
#  task_id           :integer
#  user_id           :integer
#  is_reminder       :boolean          default(FALSE)
#  is_reminder_sent  :boolean          default(FALSE)
#  reminder_datetime :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Reminder < ActiveRecord::Base
  belongs_to :task
  belongs_to :user
  attr_accessible :is_reminder_sent, :reminder_datetime, :task_id, :user_id, :is_reminder
end

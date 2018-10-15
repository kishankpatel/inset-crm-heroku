# == Schema Information
#
# Table name: email_notifications
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  due_task    :boolean
#  task_assign :boolean
#  deal_assign :boolean
#  donot_send  :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class EmailNotification < ActiveRecord::Base
  belongs_to :user
  attr_accessible :deal_assign, :donot_send, :due_task, :task_assign, :user_id
end

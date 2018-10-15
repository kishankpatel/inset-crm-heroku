# == Schema Information
#
# Table name: email_series
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  org_id          :integer
#  org_name        :string(255)
#  email           :string(255)
#  name            :string(255)
#  signup_date     :datetime
#  email_sent_for  :string(255)
#  email_sent_at   :date
#  is_next_tosend  :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  is_unsubscribe  :boolean          default(FALSE)
#  is_email_opened :boolean          default(FALSE)
#  opened_count    :integer          default(0)
#  last_opened_at  :datetime
#

class EmailSeries < ActiveRecord::Base
	belongs_to :user
	belongs_to :organization
	attr_accessible :org_id, :org_name, :name, :email, :user_id, :signup_date, :is_unsubscribe, :email_sent_for, :is_next_tosend, :email_sent_at, :is_email_opened, :opened_count, :last_opened_at
end

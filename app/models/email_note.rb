# == Schema Information
#
# Table name: email_notes
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  mail_letter_id  :integer
#  user_id         :integer
#  notes           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class EmailNote < ActiveRecord::Base
  attr_accessible :mail_letter_id, :notes, :organization_id, :user_id

  belongs_to :user
end

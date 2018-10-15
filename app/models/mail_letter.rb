# == Schema Information
#
# Table name: mail_letters
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  mailable_type   :string(255)
#  mailable_id     :integer
#  mailto          :string(255)
#  subject         :string(255)
#  description     :text
#  mail_by         :integer
#  mail_cc         :string(255)
#  mail_bcc        :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  contact_info    :text
#  mail_domain     :string(255)
#  mail_id         :string(255)
#  mail_from       :string(255)
#

class MailLetter < ActiveRecord::Base
  belongs_to :organization
  belongs_to :mailable,:polymorphic=>true
  belongs_to :user , :class_name=> "User", :foreign_key => :mail_by
  serialize :contact_info, JSON
  attr_accessible :description, :mail_bcc, :mail_by, :mail_cc, :mailable_id, :mailable_type, :mailto, :subject,:organization,:organization_id,:mailable,:contact_info,:mail_domain, :mail_id, :mail_from
  has_many :sent_email_opens
  has_many :email_notes
end

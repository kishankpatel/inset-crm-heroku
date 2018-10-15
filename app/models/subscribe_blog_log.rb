# == Schema Information
#
# Table name: subscribe_blog_logs
#
#  id            :integer          not null, primary key
#  contact_id    :integer
#  contact_email :string(255)
#  blog_title    :text
#  blog_content  :text
#  status        :string(255)
#  error_message :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class SubscribeBlogLog < ActiveRecord::Base
  attr_accessible :blog_content, :blog_title, :contact_email, :contact_id, :status, :error_message
end

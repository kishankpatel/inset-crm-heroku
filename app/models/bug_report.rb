# == Schema Information
#
# Table name: bug_reports
#
#  id          :integer          not null, primary key
#  platform    :string(255)
#  name        :string(255)
#  email       :string(255)
#  bug_type    :string(255)
#  comments    :text
#  is_resolved :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class BugReport < ActiveRecord::Base
  attr_accessible :bug_type, :comments, :email, :is_resolved, :name, :platform
end

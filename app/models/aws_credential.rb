# == Schema Information
#
# Table name: aws_credentials
#
#  id         :integer          not null, primary key
#  access_key :string(255)
#  secret_key :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AwsCredential < ActiveRecord::Base
  attr_accessible :access_key, :secret_key
end

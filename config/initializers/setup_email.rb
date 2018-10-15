# AWS_CONFIG = YAML.load(ERB.new(File.read("#{::Rails.root}/config/s3.yml")).result)
# AES_CREDENTIALS = AWS_CONFIG[::Rails.env]
  

# #ActionMailer::Base.default_charset = "iso-8859-1"
# ActionMailer::Base.delivery_method = :ses
# ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
#   :access_key_id     => AES_CREDENTIALS['access_key_id'],
#   :secret_access_key => AES_CREDENTIALS['secret_access_key']
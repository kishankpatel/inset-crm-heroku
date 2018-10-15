# S3_CONFIG = YAML.load(ERB.new(File.read("#{::Rails.root}/config/s3.yml")).result)

# S3_CREDENTIALS = S3_CONFIG[::Rails.env]
APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
OFFICE_CONFIG = YAML.load_file("#{Rails.root}/config/outlook.yml")[Rails.env]
SECRET_CONFIG = YAML.load_file("#{Rails.root}/config/secret.yml")[Rails.env]
MKTR_URL = APP_CONFIG[:marketing_url]
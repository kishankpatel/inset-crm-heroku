USER_PLAN_CONFIG = YAML.load_file("#{::Rails.root}/config/user_plan_prices.yml")
USER_PLAN_PRICES = USER_PLAN_CONFIG[::Rails.env]

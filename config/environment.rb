# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SalesCafe::Application.initialize!


ENV['cloudfront'] = ""
ENV['andolaORG'] = "3"
ENV['mode'] = Rails.env
ENV['user_plan_price'] = "4.99"

@@category = ["Skype", "GTalk", "Yahoo", "AOL", "Windows Live", "Digsby","Aim","MSN"]

@@currencies = [['United States Dollars - USD', 'USD'], ['Singapore Dollars - SGD', 'SGD'], ['Euro - EUR', 'EUR'], ['India Rupees - INR', 'INR'], ['United Kingdom Pounds - GBP', 'GBP'],['Algeria Dinars – DZD', 'DZD']]
@@period = ["Month", "Week"]
@@billing_type = ["Fixed bid", "Per hour", "Per day", "Per week", "Per month", "Custom"]

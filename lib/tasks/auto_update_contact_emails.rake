# require "#{Rails.root}/app/helpers/auth_helper"
# include AuthHelper
# namespace :wus do
#    task :auto_update_contact_emails => :environment do
#       organization = Organization.find(73)
#       organization.users.each do |user|
#         set_contact_mail_letters(user)
#       end
#    end
# end
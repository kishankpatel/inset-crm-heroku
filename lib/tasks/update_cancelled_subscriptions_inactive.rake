namespace :wus do  
  #Update organization subscriptions as inactive for cancelled subscriptions
  task :update_cancelled_subscriptions_inactive => :environment do
    UserSubscription.where("is_cancel = ? AND DATE(next_billing_date) = ?", true, Date.today).each do |user_subscription|
      my_logger ||= Logger.new("#{Rails.root}/log/cancelled_subscriptions.log")
      my_logger.info("--------parameters--------------at---"+ Time.now.to_s + "-----------")
      puts "----------------- Started ----------------"
      user_subscription.update_column :is_active, false
      user_subscription.organization.update_column :is_sub_active, false
      my_logger.info("----------------- Organization Name: #{user_subscription.organization.name} with ID: #{user_subscription.organization.id} and subscription id: #{user_subscription.id}")
      my_logger.info("------------------------end------------------------\n")
      puts "------- Completed organization Name: #{user_subscription.organization.name} with ID: #{user_subscription.organization.id} and subscription id: #{user_subscription.id}"
    end
  end
end
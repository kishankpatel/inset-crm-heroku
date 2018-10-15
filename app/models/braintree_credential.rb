class BraintreeCredential < ActiveRecord::Base
  attr_accessible :environment, :merchant_id, :private_key, :public_key
end

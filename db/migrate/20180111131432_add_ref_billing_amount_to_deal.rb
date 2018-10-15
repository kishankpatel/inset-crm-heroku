class AddRefBillingAmountToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :ref_billing_amount, :float
  end
end

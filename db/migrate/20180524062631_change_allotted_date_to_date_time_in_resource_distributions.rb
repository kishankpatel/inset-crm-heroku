class ChangeAllottedDateToDateTimeInResourceDistributions < ActiveRecord::Migration
  def up
     change_table :resource_distributions do |t|
        t.change :allotted_date, :datetime
      end
  end

  def down
      change_table :resource_distributions do |t|
        t.change :allotted_date, :date
      end
  end
end

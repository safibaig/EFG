class RemovePaymentPeriodFromLoans < ActiveRecord::Migration
  def up
    execute 'UPDATE loans SET repayment_frequency_id = payment_period WHERE payment_period IS NOT NULL'
    remove_column :loans, :payment_period
  end

  def down
    add_column :loans, :payment_period, :integer
    execute 'UPDATE loans SET payment_period = repayment_frequency_id'
  end
end

class AddRepaymentDurationToLoanChange < ActiveRecord::Migration
  def change
    add_column :loan_modifications, :old_repayment_duration, :integer
    add_column :loan_modifications, :repayment_duration, :integer
  end
end
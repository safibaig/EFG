class RenameLoanTermToRepaymentDuration < ActiveRecord::Migration
  def up
    rename_column :loan_modifications, :loan_term, :repayment_duration
    rename_column :loan_modifications, :old_loan_term, :old_repayment_duration
  end

  def down
    rename_column :loan_modifications, :repayment_duration, :loan_term
    rename_column :loan_modifications, :old_repayment_duration, :old_loan_term
  end
end

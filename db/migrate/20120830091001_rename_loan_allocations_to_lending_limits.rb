class RenameLoanAllocationsToLendingLimits < ActiveRecord::Migration
  def up
    rename_table :loan_allocations, :lending_limits
    rename_index :lending_limits, 'index_loan_allocations_on_lender_id', 'index_lending_limits_on_lender_id'
    rename_column :loans, :loan_allocation_id, :lending_limit_id
    rename_index :loans, 'index_loans_on_loan_allocation_id', 'index_loans_on_lending_limit_id'
  end

  def down
    rename_index :loans, 'index_loans_on_lending_limit_id', 'index_loans_on_loan_allocation_id'
    rename_column :loans, :lending_limit_id, :loan_allocation_id
    rename_index :lending_limits, 'index_lending_limits_on_lender_id', 'index_loan_allocations_on_lender_id'
    rename_table :lending_limits, :loan_allocations
  end
end

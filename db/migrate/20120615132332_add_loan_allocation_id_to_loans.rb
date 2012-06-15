class AddLoanAllocationIdToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :loan_allocation_id, :integer
    add_index :loans, :loan_allocation_id
  end
end

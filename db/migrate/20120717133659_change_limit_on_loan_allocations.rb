class ChangeLimitOnLoanAllocations < ActiveRecord::Migration
  def up
    change_column :loan_allocations, :allocation, :integer, limit: 8
  end

  def down
    change_column :loan_allocations, :allocation, :integer
  end
end

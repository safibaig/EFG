class AddModifiedByIdToLoanAllocations < ActiveRecord::Migration
  def up
    add_column :loan_allocations, :modified_by_id, :integer
    change_column_default :loan_allocations, :active, false
    change_column_null :loan_allocations, :active, false
  end

  def down
    change_column_null :loan_allocations, :active, true
    change_column_default :loan_allocations, :active, nil
    remove_column :loan_allocations, :modified_by_id
  end
end

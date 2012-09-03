class AddModifiedByIdToLoanAllocations < ActiveRecord::Migration
  def up
    add_column :loan_allocations, :modified_by_id, :integer
    change_column_default :loan_allocations, :active, false
    change_column_null :loan_allocations, :active, false
    rename_column :loan_allocations, :allocation_type, :allocation_type_id
    change_column_null :loan_allocations, :lender_id, false
    change_column_null :loan_allocations, :allocation, false
    change_column_null :loan_allocations, :allocation_type_id, false
    change_column_null :loan_allocations, :starts_on, false
    change_column_null :loan_allocations, :ends_on, false
    change_column_null :loan_allocations, :description, false
    change_column_null :loan_allocations, :premium_rate, false
    change_column_null :loan_allocations, :guarantee_rate, false
  end

  def down
    change_column_null :loan_allocations, :guarantee_rate, false
    change_column_null :loan_allocations, :premium_rate, false
    change_column_null :loan_allocations, :description, false
    change_column_null :loan_allocations, :ends_on, true
    change_column_null :loan_allocations, :starts_on, true
    change_column_null :loan_allocations, :allocation_type_id, true
    change_column_null :loan_allocations, :allocation, false
    change_column_null :loan_allocations, :lender_id, false
    rename_column :loan_allocations, :allocation_type_id, :allocation_type
    change_column_null :loan_allocations, :active, true
    change_column_default :loan_allocations, :active, nil
    remove_column :loan_allocations, :modified_by_id
  end
end

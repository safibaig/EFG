class IndexRecoveriesByLoanId < ActiveRecord::Migration
  def up
    add_index :recoveries, :loan_id
  end

  def down
    remove_index :recoveries, :loan_id
  end
end

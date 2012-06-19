class AddLenderIdIndexToLoans < ActiveRecord::Migration
  def change
    add_index :loans, :lender_id
  end
end

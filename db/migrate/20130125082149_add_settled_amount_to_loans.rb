class AddSettledAmountToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :settled_amount, :integer
  end
end
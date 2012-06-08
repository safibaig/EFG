class AddLenderDemandColumnsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :borrower_demanded_on, :date
    add_column :loans, :borrower_demanded_amount, :integer
  end
end

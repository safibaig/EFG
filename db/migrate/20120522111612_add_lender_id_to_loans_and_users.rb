class AddLenderIdToLoansAndUsers < ActiveRecord::Migration
  def change
    add_column :loans, :lender_id, :integer, null: false
    add_column :users, :lender_id, :integer, null: false
  end
end

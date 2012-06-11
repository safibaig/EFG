class AddRepaidToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :repaid_on, :date
  end
end

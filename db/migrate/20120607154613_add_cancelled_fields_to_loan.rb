class AddCancelledFieldsToLoan < ActiveRecord::Migration
  def change
    add_column :loans, :cancelled_on, :date
    add_column :loans, :cancelled_reason, :integer
    add_column :loans, :cancelled_comment, :text
  end
end

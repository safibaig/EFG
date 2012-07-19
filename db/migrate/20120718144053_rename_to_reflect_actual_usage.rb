class RenameToReflectActualUsage < ActiveRecord::Migration
  def up
    rename_column :loans, :borrower_demanded_amount, :amount_demanded
  end

  def down
    rename_column :loans, :amount_demanded, :borrower_demanded_amount
  end
end

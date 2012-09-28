class LoansLegacySmallLoanNotNullable < ActiveRecord::Migration
  def up
    change_column :loans, :legacy_small_loan, :boolean, null: false, default: false
  end

  def down
    change_column :loans, :legacy_small_loan, :boolean, null: true, default: nil
  end
end

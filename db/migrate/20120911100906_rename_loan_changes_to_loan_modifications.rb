class RenameLoanChangesToLoanModifications < ActiveRecord::Migration
  def change
    rename_table :loan_changes, :loan_modifications
    add_column :loan_modifications, :type, :string
    execute 'UPDATE loan_modifications SET type = "LoanChange"'
  end
end

class MatchLoanChangesColumnNames < ActiveRecord::Migration
  def up
    rename_column :loan_changes, :cap_id, :lending_limit_id
    rename_column :loan_changes, :old_cap_id, :old_lending_limit_id
    rename_column :loan_changes, :guaranteed_date, :guaranteed_on
    rename_column :loan_changes, :old_guaranteed_date, :old_guaranteed_on
    rename_column :loans, :branch_sortcode, :sortcode
  end

  def down
    rename_column :loans, :sortcode, :branch_sortcode
    rename_column :loan_changes, :old_guaranteed_on, :old_guaranteed_date
    rename_column :loan_changes, :guaranteed_on, :guaranteed_date
    rename_column :loan_changes, :old_lending_limit_id, :old_cap_id
    rename_column :loan_changes, :lending_limit_id, :cap_id
  end
end

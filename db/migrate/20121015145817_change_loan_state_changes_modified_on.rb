class ChangeLoanStateChangesModifiedOn < ActiveRecord::Migration
  def up
    change_column :loan_state_changes, :modified_on, :datetime
    rename_column :loan_state_changes, :modified_on, :modified_at
  end

  def down
    rename_column :loan_state_changes, :modified_at, :modified_on
    change_column :loan_state_changes, :modified_on, :date
  end
end

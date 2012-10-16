class ChangeLoanStateChangesIndex < ActiveRecord::Migration
  def up
    remove_index :loan_state_changes, name: 'loan_association'
    add_index :loan_state_changes, [:loan_id, :modified_at], name: 'loan_association'
  end

  def down
    remove_index :loan_state_changes, name: 'loan_association'
    add_index :loan_state_changes, [:loan_id, :modified_at, :id], name: 'loan_association'
  end
end

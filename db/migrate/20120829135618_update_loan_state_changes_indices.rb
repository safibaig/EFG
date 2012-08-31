class UpdateLoanStateChangesIndices < ActiveRecord::Migration
  def up
    remove_index :loan_state_changes, :loan_id
    add_index :loan_state_changes, [:loan_id, :modified_on, :id], name: 'loan_association'
  end

  def down
    add_index :loan_state_changes, :loan_id
    remove_index :loan_state_changes, name: 'loan_association'
  end
end

class MakeRecoveryFieldsNullable < ActiveRecord::Migration
  def up
    change_column_null :recoveries, :realisations_due_to_gov, true
    change_column_null :recoveries, :amount_due_to_dti, false
  end

  def down
    change_column_null :recoveries, :realisations_due_to_gov, false
    change_column_null :recoveries, :amount_due_to_dti, true
  end
end

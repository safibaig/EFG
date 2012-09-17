class FixLoanModificationTypes < ActiveRecord::Migration
  def up
    execute 'UPDATE loan_modifications SET type = "InitialDrawChange" WHERE change_type_id IS NULL'
    execute 'UPDATE loan_modifications SET type = "DataCorrection"    WHERE change_type_id = "9"'
  end

  def down
  end
end

class MigrateBusinessNameChangesToDataCorrections < ActiveRecord::Migration
  def up
    execute 'UPDATE loan_modifications SET type = "DataCorrection" WHERE change_type_id = "1"'
  end

  def down
    execute 'UPDATE loan_modifications SET type = "LoanChange" WHERE change_type_id = "1"'
  end
end

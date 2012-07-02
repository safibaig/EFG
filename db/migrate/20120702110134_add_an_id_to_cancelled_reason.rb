class AddAnIdToCancelledReason < ActiveRecord::Migration
  def change
    rename_column :loans, :cancelled_reason, :cancelled_reason_id
  end
end

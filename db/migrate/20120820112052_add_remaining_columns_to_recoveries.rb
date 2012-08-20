class AddRemainingColumnsToRecoveries < ActiveRecord::Migration
  def change
    add_column :recoveries, :ar_insert_timestamp, :string
    add_column :recoveries, :ar_timestamp, :string
    add_column :recoveries, :legacy_created_by, :string
    add_column :recoveries, :legacy_loan_id, :string
    add_column :recoveries, :seq, :string
  end
end

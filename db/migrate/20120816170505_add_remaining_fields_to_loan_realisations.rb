class AddRemainingFieldsToLoanRealisations < ActiveRecord::Migration
  def change
    add_column :loan_realisations, :legacy_loan_id, :integer
    add_column :loan_realisations, :legacy_created_by, :string
    add_column :loan_realisations, :realised_on, :date
    add_column :loan_realisations, :seq, :string
    add_column :loan_realisations, :ar_timestamp, :string
    add_column :loan_realisations, :ar_insert_timestamp, :string
  end
end

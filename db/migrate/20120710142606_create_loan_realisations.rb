class CreateLoanRealisations < ActiveRecord::Migration
  def change
    create_table :loan_realisations do |t|
      t.integer :realised_loan_id, :realisation_statement_id
      t.timestamps
    end

    add_index :loan_realisations, :realised_loan_id
    add_index :loan_realisations, :realisation_statement_id
  end
end

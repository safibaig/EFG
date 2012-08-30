class CreateLoanIneligibilityReasons < ActiveRecord::Migration
  def change
    create_table :loan_ineligibility_reasons do |t|
      t.references :loan
      t.text :reason
      t.integer :sequence, default: 0, null: false
      t.datetime :ar_timestamp
      t.datetime :ar_insert_timestamp
      t.timestamps
    end

    add_index :loan_ineligibility_reasons, :loan_id
  end
end

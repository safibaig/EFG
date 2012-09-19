class CreateDemandToBorrowers < ActiveRecord::Migration
  def change
    create_table :demand_to_borrowers do |t|
      t.integer :loan_id, null: false
      t.integer :seq, null: false
      t.integer :created_by_id, null: false
      t.date :date_of_demand, null: false
      t.integer :demanded_amount, limit: 8, null: false
      t.date :modified_date, null: false
      t.integer :legacy_loan_id
      t.string :legacy_created_by
      t.datetime :ar_timestamp
      t.datetime :ar_insert_timestamp
      t.timestamps
    end

    add_index :demand_to_borrowers, [:loan_id, :seq], unique: true
  end
end

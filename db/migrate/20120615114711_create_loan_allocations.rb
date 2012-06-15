class CreateLoanAllocations < ActiveRecord::Migration
  def change
    create_table :loan_allocations do |t|
      t.references :lender
      t.integer :legacy_id
      t.integer :lender_legacy_id
      t.integer :version
      t.integer :allocation_type
      t.boolean :active
      t.integer :allocation
      t.date :starts_on
      t.date :ends_on
      t.string :description
      t.string :modified_by_legacy_id
      t.datetime :ar_timestamp
      t.datetime :ar_insert_timestamp
      t.decimal :premium_rate, precision: 16, scale: 2
      t.decimal :guarantee_rate, precision: 16, scale: 2

      t.timestamps
    end

    add_index :loan_allocations, :lender_id
  end
end

class CreateLoanStateChanges < ActiveRecord::Migration
  def change
    create_table :loan_state_changes do |t|
      t.references :loan
      t.string :legacy_id
      t.string :state
      t.integer :version
      t.integer :modified_by_id, null: false
      t.string :modified_by_legacy_id
      t.integer :event_id, null: false
      t.date :modified_on
      t.datetime :ar_timestamp
      t.datetime :ar_insert_timestamp
      t.timestamps
    end

    add_index :loan_state_changes, :loan_id
  end
end

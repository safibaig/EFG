class CreateLoanChanges < ActiveRecord::Migration
  def change
    create_table :loan_changes do |t|
      t.integer :loan_id, null: false
      t.integer :created_by_id, null: false
      t.string :oid
      t.integer :seq, default: 0, null: false
      t.date :date_of_change, null: false
      t.date :maturity_date
      t.date :old_maturity_date
      t.string :business_name
      t.string :old_business_name
      t.integer :lump_sum_repayment
      t.integer :amount_drawn
      t.date :modified_date, null: false
      t.string :modified_user
      t.integer :change_type
      t.datetime :ar_timestamp
      t.datetime :ar_insert_timestamp
      t.integer :amount
      t.integer :old_amount
      t.date :guaranteed_date
      t.date :old_guaranteed_date
      t.date :initial_draw_date
      t.date :old_initial_draw_date
      t.integer :initial_draw_amount
      t.integer :old_initial_draw_amount
      t.string :sortcode
      t.string :old_sortcode
      t.integer :dti_demand_out_amount
      t.integer :old_dti_demand_out_amount
      t.integer :dti_demand_interest
      t.integer :old_dti_demand_interest
      t.integer :cap_id
      t.integer :old_cap_id
      t.integer :loan_term
      t.integer :old_loan_term

      t.timestamps
    end

    add_index :loan_changes, [:loan_id, :seq], unique: true
  end
end

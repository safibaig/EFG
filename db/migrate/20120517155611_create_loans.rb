class CreateLoans < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.boolean :viable_proposition, null: false
      t.boolean :would_you_lend, null: false
      t.boolean :collateral_exhausted, null: false
      t.integer :amount, null: false
      t.integer :lender_cap, null: false
      t.integer :repayment_duration, null: false
      t.integer :turnover, null: false
      t.date :trading_date, null: false
      t.string :sic_code, null: false
      t.integer :loan_category, null: false
      t.integer :reason, null: false
      t.boolean :previous_borrowing, null: false
      t.boolean :private_residence_charge_required, null: false
      t.boolean :personal_guarantee_required, null: false
      t.timestamps
    end
  end
end

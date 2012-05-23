class CreateStateAidCalculations < ActiveRecord::Migration
  def change
    create_table :state_aid_calculations do |t|
      t.integer :loan_id, null: false
      t.integer :initial_draw_year, null: false
      t.integer :initial_draw_amount, null: false
      t.integer :initial_draw_months, null: false
      t.integer :initial_capital_repayment_holiday
      t.integer :second_draw_amount
      t.integer :second_draw_months
      t.integer :third_draw_amount
      t.integer :third_draw_months
      t.integer :fourth_draw_amount
      t.integer :fourth_draw_months
      t.timestamps
    end

    add_index :state_aid_calculations, :loan_id
  end
end

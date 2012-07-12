class CreateRecoveries < ActiveRecord::Migration
  def change
    create_table :recoveries do |t|
      t.integer :loan_id, null: false
      t.date :recovered_on, null: false
      t.integer :total_proceeds_recovered
      t.integer :total_liabilities_after_demand
      t.integer :total_liabilities_behind
      t.integer :additional_break_costs
      t.integer :additional_interest_accrued
      t.integer :amount_due_to_dti
      t.boolean :realise_flag
      t.integer :created_by_id, null: false
      t.integer :outstanding_non_efg_debt, null: false
      t.integer :non_linked_security_proceeds, null: false
      t.integer :linked_security_proceeds, null: false
      t.integer :realisations_attributable, null: false
      t.integer :realisations_due_to_gov, null: false
      t.timestamps
    end
  end
end

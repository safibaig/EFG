class UpdateMoneyFieldsLength < ActiveRecord::Migration
  def up
    money_fields.each do |table_name, fields|
      fields.each { |field| change_column table_name, field, :integer, limit: 8 }
    end
  end

  def down
    money_fields.each do |table_name, fields|
      fields.each { |field| change_column table_name, field, :integer }
    end
  end

  private

  def money_fields
    {
      loans: [
        :amount,
        :fees,
        :initial_draw_value,
        :turnover,
        :outstanding_amount,
        :amount_demanded,
        :dti_demand_outstanding,
        :dti_amount_claimed,
        :dti_interest,
        :dit_break_costs,
        :current_refinanced_value,
        :final_refinanced_value,
        :borrower_demand_outstanding,
        :state_aid,
        :overdraft_limit,
        :invoice_discount_limit,
        :remove_guarantee_outstanding_amount
      ],
      loan_changes: [
        :lump_sum_repayment,
        :amount_drawn,
        :amount,
        :old_amount,
        :initial_draw_amount,
        :old_initial_draw_amount,
        :dti_demand_out_amount,
        :old_dti_demand_out_amount,
        :dti_demand_interest,
        :old_dti_demand_interest
      ],
      loan_realisations: [
        :realised_amount
      ],
      recoveries: [
        :outstanding_non_efg_debt,
        :non_linked_security_proceeds,
        :linked_security_proceeds,
        :realisations_attributable,
        :amount_due_to_dti,
        :total_proceeds_recovered,
        :total_liabilities_after_demand,
        :total_liabilities_behind,
        :additional_break_costs,
        :additional_interest_accrued,
        :realisations_due_to_gov
      ],
      state_aid_calculations: [
        :initial_draw_amount,
        :second_draw_amount,
        :third_draw_amount,
        :fourth_draw_amount
      ]
    }
  end
end
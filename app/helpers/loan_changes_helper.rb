module LoanChangesHelper

  def state_aid_calculation_hidden_fields(hash)
    if hash.is_a?(Hash)
      %w(
        premium_cheque_month
        initial_draw_amount
        initial_draw_months
        initial_capital_repayment_holiday
        second_draw_amount
        second_draw_months
        third_draw_amount
        third_draw_months
        fourth_draw_amount
        fourth_draw_months
        rescheduling
      ).collect do |field|
        hidden_field_tag "state_aid_calculation[#{field}]", hash[field.to_sym]
      end.join.html_safe
    end
  end

end

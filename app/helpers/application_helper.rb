module ApplicationHelper
  def humanize_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def state_aid_calculation_path_for_loan(loan)
    loan.has_state_aid_calculation? ?
      edit_loan_state_aid_calculation_path(loan) :
      new_loan_state_aid_calculation_path(loan)
  end
end

class StateAidCalculationVariant::TransferredLoanEntry < StateAidCalculationVariant::Base

  def to_param
    'transferred_loan_entry'
  end

  def leave_state_aid_calculation_path(loan)
    new_loan_transferred_entry_path(loan)
  end
end

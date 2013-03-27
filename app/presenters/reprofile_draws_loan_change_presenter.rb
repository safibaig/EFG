class ReprofileDrawsLoanChangePresenter < LoanChangePresenter
  private
    def update_loan_change
      loan_change.change_type_id = ChangeType::ReprofileDraws.id
    end
end

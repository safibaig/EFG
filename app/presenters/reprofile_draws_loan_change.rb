class ReprofileDrawsLoanChange < LoanChangePresenter
  private
    def update_loan_change
      loan_change.change_type = ChangeType::ReprofileDraws
    end
end

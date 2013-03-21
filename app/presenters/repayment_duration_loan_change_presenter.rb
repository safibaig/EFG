class RepaymentDurationLoanChangePresenter < LoanChangePresenter
  attr_reader :maturity_date, :added_months, :repayment_duration
  attr_accessible :added_months

  validate :must_not_be_zero_months
  validate :ensure_valid_repayment_duration_and_maturity_date

  def added_months=(value)
    @added_months = value.to_i
  end

  private
    def ensure_valid_repayment_duration_and_maturity_date
      return if added_months.zero?

      rd = RepaymentDuration.new(loan)
      @repayment_duration = loan.repayment_duration.total_months + added_months

      errors.add(:added_months, 'too short') if repayment_duration < rd.min_months
      errors.add(:added_months, 'too long') if repayment_duration > rd.max_months

      initial_draw_date = loan.initial_draw_change.date_of_change
      @maturity_date = initial_draw_date.advance(months: @repayment_duration)
    end

    def must_not_be_zero_months
      errors.add(:added_months, 'cannot be zero') if added_months.present? && added_months.to_i.zero?
    end

    def update_loan
      loan.repayment_duration = repayment_duration
      loan.maturity_date = maturity_date
    end

    def update_loan_change
      loan_change.change_type_id = (added_months > 0 ? ChangeType::ExtendTerm : ChangeType::DecreaseTerm).id
      loan_change.repayment_duration = repayment_duration
      loan_change.old_repayment_duration = loan.repayment_duration.total_months
      loan_change.maturity_date = maturity_date
      loan_change.old_maturity_date = loan.maturity_date
    end
end

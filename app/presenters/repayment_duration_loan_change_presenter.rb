class RepaymentDurationLoanChangePresenter < LoanChangePresenter
  attr_reader :maturity_date, :added_months, :repayment_duration
  attr_accessible :added_months

  validate :validate_added_months

  def added_months=(value)
    @added_months = value.present? ? value.to_i : nil
  end

  def repayment_duration_at_next_premium
    months = super
    months += added_months if added_months
    months
  end

  private
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

    def validate_added_months
      if added_months.nil?
        errors.add(:added_months, :required)
      elsif added_months.zero?
        errors.add(:added_months, :must_not_be_zero)
      else
        rd = RepaymentDuration.new(loan)
        @repayment_duration = loan.repayment_duration.total_months + added_months

        if repayment_duration <= 0
          errors.add(:added_months, :must_be_gt_zero)
        elsif repayment_duration < rd.min_months
          errors.add(:added_months, :too_short, count: rd.min_months)
        elsif repayment_duration > rd.max_months
          errors.add(:added_months, :too_long,  count: rd.max_months)
        end

        initial_draw_date = loan.initial_draw_change.date_of_change
        @maturity_date = initial_draw_date.advance(months: @repayment_duration)
      end
    end
end

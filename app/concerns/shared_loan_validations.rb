module SharedLoanValidations
  extend ActiveSupport::Concern

  private

  def repayment_plan_is_allowed
    repayment_duration_within_loan_category_limits

    if errors[:repayment_duration].blank?
      repayment_frequency_allowed
    end
  end

  def repayment_duration_within_loan_category_limits
    repayment_months = repayment_duration.try(:total_months)
    loan_term = LoanTerm.new(loan)

    if repayment_months
      unless repayment_months >= loan_term.min_months && repayment_months <= loan_term.max_months
        errors.add(:repayment_duration, :not_allowed)
      end
    end
  end

  def repayment_frequency_allowed
    return unless repayment_frequency_id.present? && repayment_duration.present?
    case repayment_frequency_id
    when 1
      errors.add(:repayment_frequency_id, :not_allowed) unless repayment_duration.total_months % 12 == 0
    when 2
      errors.add(:repayment_frequency_id, :not_allowed) unless repayment_duration.total_months % 6 == 0
    when 3
      errors.add(:repayment_frequency_id, :not_allowed) unless repayment_duration.total_months % 3 == 0
    end
  end

end

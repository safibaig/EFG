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
    loan_term = repayment_duration.try(:total_months)
    category = LoanCategory.find(loan_category_id)

    if category && loan_term
      unless loan_term >= category.min_loan_term && loan_term <= category.max_loan_term
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

class LoanChange < LoanModification
  validates_inclusion_of :change_type_id, in: %w(2 3 4 5 6 7 8 a), strict: true
  validate :validate_non_negative_amounts

  def change_type
    ChangeType.find(change_type_id)
  end

  def change_type_name
    change_type.name
  end

  private
    def validate_non_negative_amounts
      errors.add(:amount_drawn, :not_be_negative) if amount_drawn && amount_drawn < 0
      errors.add(:lump_sum_repayment, :not_be_negative) if lump_sum_repayment && lump_sum_repayment < 0
    end
end

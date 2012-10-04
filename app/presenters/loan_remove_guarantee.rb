class LoanRemoveGuarantee
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Guaranteed], to: Loan::Removed, event: :remove_guarantee

  attribute :remove_guarantee_on
  attribute :remove_guarantee_outstanding_amount
  attribute :remove_guarantee_reason

  validates_presence_of :remove_guarantee_on, :remove_guarantee_outstanding_amount, :remove_guarantee_reason

  validate :remove_guarantee_outstanding_amount_is_not_greater_than_total_drawn_amount

  private

  def remove_guarantee_outstanding_amount_is_not_greater_than_total_drawn_amount
    return if remove_guarantee_outstanding_amount.blank?
    if remove_guarantee_outstanding_amount > loan.cumulative_drawn_amount
      errors.add(:remove_guarantee_outstanding_amount, :greater_than_total_drawn_amount)
    end
  end

end

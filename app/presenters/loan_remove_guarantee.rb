class LoanRemoveGuarantee
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Guaranteed], to: Loan::Removed, event: :remove_guarantee

  attribute :remove_guarantee_on
  attribute :remove_guarantee_outstanding_amount
  attribute :remove_guarantee_reason

  validates_presence_of :remove_guarantee_on, :remove_guarantee_outstanding_amount, :remove_guarantee_reason

  validate :remove_guarantee_outstanding_amount_is_not_greater_than_total_drawn_amount, if: :remove_guarantee_outstanding_amount

  validate :remove_guarantee_on_is_not_before_initial_draw_date, if: :remove_guarantee_on

  private

  def remove_guarantee_outstanding_amount_is_not_greater_than_total_drawn_amount
    if remove_guarantee_outstanding_amount > loan.cumulative_drawn_amount
      errors.add(:remove_guarantee_outstanding_amount, :greater_than_total_drawn_amount)
    end
  end

  def remove_guarantee_on_is_not_before_initial_draw_date
    if remove_guarantee_on < loan.initial_draw_change.date_of_change
      errors.add(:remove_guarantee_on, :before_initial_draw_date)
    end
  end

end

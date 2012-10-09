class LoanRepay
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Guaranteed, Loan::LenderDemand], to: Loan::Repaid, event: :loan_repaid

  attribute :repaid_on

  validates_presence_of :repaid_on

  validate :repaid_on_is_not_before_initial_draw_date

  private

  def repaid_on_is_not_before_initial_draw_date
    return if repaid_on.blank? || loan.initial_draw_change.blank?

    if repaid_on < loan.initial_draw_change.date_of_change
      errors.add(:repaid_on, :before_initial_draw_date)
    end
  end

end

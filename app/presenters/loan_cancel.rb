class LoanCancel
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Completed, Loan::Eligible, Loan::Incomplete, Loan::Offered], to: Loan::Cancelled, event: :cancel_loan

  attribute :cancelled_reason_id
  attribute :cancelled_comment
  attribute :cancelled_on

  validates_presence_of :cancelled_reason_id, :cancelled_comment, :cancelled_on

  validate :cancelled_on_is_not_before_loan_creation_date, if: :cancelled_on

  private

  def cancelled_on_is_not_before_loan_creation_date
    if cancelled_on < loan.created_at.to_date
      errors.add(:cancelled_on, :before_loan_creation_date)
    end
  end
end

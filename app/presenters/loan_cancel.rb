class LoanCancel
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Eligible, Loan::Incomplete], to: Loan::Cancelled

  attribute :cancelled_reason
  attribute :cancelled_comment
  attribute :cancelled_on

  validates_presence_of :cancelled_reason, :cancelled_comment, :cancelled_on
end

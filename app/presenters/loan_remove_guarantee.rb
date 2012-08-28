class LoanRemoveGuarantee
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Guaranteed], to: Loan::Removed, event: :remove_guarantee

  attribute :remove_guarantee_on
  attribute :remove_guarantee_outstanding_amount
  attribute :remove_guarantee_reason

  validates_presence_of :remove_guarantee_on, :remove_guarantee_outstanding_amount, :remove_guarantee_reason

end

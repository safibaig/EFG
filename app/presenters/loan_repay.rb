class LoanRepay
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Guaranteed, Loan::LenderDemand], to: Loan::Repaid, event: :loan_repaid

  attribute :repaid_on

  validates_presence_of :repaid_on
end

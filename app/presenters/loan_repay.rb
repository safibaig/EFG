class LoanRepay
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Guaranteed, Loan::LenderDemand], to: Loan::Repaid

  attribute :repaid_on

  validates_presence_of :repaid_on
end

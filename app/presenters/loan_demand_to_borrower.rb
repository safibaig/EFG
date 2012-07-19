class LoanDemandToBorrower
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Guaranteed, to: Loan::LenderDemand

  attribute :borrower_demanded_on
  attribute :borrower_demand_outstanding

  validates_presence_of :borrower_demand_outstanding, :borrower_demanded_on
end

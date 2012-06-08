class LoanNoClaim
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::LenderDemand, to: Loan::NotDemanded

  attribute :no_claim_on

  validates_presence_of :no_claim_on
end

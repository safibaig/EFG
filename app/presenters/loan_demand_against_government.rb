class LoanDemandAgainstGovernment
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::LenderDemand, to: Loan::Demanded

  attribute :dti_demanded_on
  attribute :dti_demand_outstanding
  attribute :dti_reason

  validates_presence_of :dti_demanded_on, :dti_demand_outstanding, :dti_reason
end

class LoanDemandAgainstGovernment
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::LenderDemand, to: Loan::Demanded, event: :demand_against_government_guarantee

  attribute :dti_demand_outstanding
  attribute :dti_demanded_on
  attribute :dti_ded_code
  attribute :dti_reason

  validates_presence_of :dti_demand_outstanding, :dti_demanded_on, :dti_ded_code
end

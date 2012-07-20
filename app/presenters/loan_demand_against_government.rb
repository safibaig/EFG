class LoanDemandAgainstGovernment
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::LenderDemand, to: Loan::Demanded

  attribute :amount_demanded
  attribute :dti_demanded_on
  attribute :dti_ded_code
  attribute :dti_reason

  validates_presence_of :amount_demanded, :dti_demanded_on, :dti_reason,
    :dti_ded_code
end

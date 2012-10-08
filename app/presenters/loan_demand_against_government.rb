class LoanDemandAgainstGovernment
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::LenderDemand, to: Loan::Demanded, event: :demand_against_government_guarantee

  attribute :dti_demand_outstanding
  attribute :dti_demanded_on
  attribute :dti_ded_code
  attribute :dti_reason
  attribute :dti_interest
  attribute :dti_break_costs

  validates_presence_of :dti_demand_outstanding, :dti_demanded_on, :dti_ded_code

  validates_presence_of :dti_interest, :dti_break_costs, unless: :efg_loan?

  validate :dti_demand_outstanding_is_not_greater_than_total_drawn_amount, if: :dti_demand_outstanding

  validate :dti_demanded_on_is_not_before_borrower_demanded_on, if: :dti_demanded_on

  delegate :efg_loan?, to: :loan

  private

  def dti_demand_outstanding_is_not_greater_than_total_drawn_amount
    if dti_demand_outstanding > loan.cumulative_drawn_amount
      errors.add(:dti_demand_outstanding, :greater_than_total_drawn_amount)
    end
  end

  def dti_demanded_on_is_not_before_borrower_demanded_on
    if dti_demanded_on < loan.borrower_demanded_on
      errors.add(:dti_demanded_on, :before_borrower_demand_date)
    end
  end
end

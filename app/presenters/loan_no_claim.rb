class LoanNoClaim
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::LenderDemand, to: Loan::NotDemanded, event: :not_demanded

  attribute :no_claim_on

  validates_presence_of :no_claim_on
  validate :validate_no_claim_on_after_last_demand_to_borrower, if: :no_claim_on

  private
    def validate_no_claim_on_after_last_demand_to_borrower
      if no_claim_on < loan.borrower_demanded_on
        errors.add(:no_claim_on, :must_be_gte_last_demand_to_borrower)
      end
    end
end

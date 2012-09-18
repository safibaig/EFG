class LoanDemandToBorrower
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Guaranteed, to: Loan::LenderDemand, event: :demand_to_borrower

  after_save :create_demand_to_borrower

  attribute :borrower_demanded_on
  attribute :borrower_demand_outstanding

  validates_presence_of :borrower_demand_outstanding, :borrower_demanded_on

  private
    def create_demand_to_borrower
      loan.demand_to_borrowers.create! do |demand_to_borrower|
        demand_to_borrower.created_by = modified_by
        demand_to_borrower.date_of_demand = borrower_demanded_on
        demand_to_borrower.demanded_amount = borrower_demand_outstanding
        demand_to_borrower.modified_date = Date.current
      end
    end
end

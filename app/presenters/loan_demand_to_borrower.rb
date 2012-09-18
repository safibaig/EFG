class LoanDemandToBorrower
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Guaranteed, to: Loan::LenderDemand, event: :demand_to_borrower

  after_save :create_demand_to_borrower

  attribute :amount_demanded
  attribute :borrower_demanded_on

  validates_presence_of :amount_demanded
  validates_presence_of :borrower_demanded_on
  validate :validate_lte_loan_cumulative_drawn_amount, if: :amount_demanded
  validate :validate_before_loan_initial_draw_date, if: :borrower_demanded_on

  private
    def create_demand_to_borrower
      loan.demand_to_borrowers.create! do |demand_to_borrower|
        demand_to_borrower.created_by = modified_by
        demand_to_borrower.date_of_demand = borrower_demanded_on
        demand_to_borrower.demanded_amount = amount_demanded
        demand_to_borrower.modified_date = Date.current
      end
    end

    def validate_lte_loan_cumulative_drawn_amount
      if amount_demanded > loan.cumulative_drawn_amount
        errors.add(:amount_demanded, :must_be_lte_loan_cumulative_drawn_amount)
      end
    end

    def validate_before_loan_initial_draw_date
      if borrower_demanded_on < loan.initial_draw_change.date_of_change
        errors.add(:borrower_demanded_on, :must_be_before_loan_initial_draw_date)
      end
    end
end

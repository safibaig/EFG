class LoanRepay
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Guaranteed, Loan::LenderDemand], to: Loan::Repaid

  attribute :repaid_on

  validates_presence_of :repaid_on

  def repaid_on=(value)
    loan.repaid_on = QuickDateFormatter.parse(value)
  end
end

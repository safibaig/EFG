class LoanAllocation < ActiveRecord::Base
  include FormatterConcern

  # TODO: verify these are the correct states
  USAGE_LOAN_STATES = [
    Loan::Guaranteed,
    Loan::LenderDemand,
    Loan::Repaid,
    Loan::Removed,
    Loan::RepaidFromTransfer,
    Loan::AutoRemoved,
    Loan::NotDemanded,
    Loan::Demanded,
    Loan::Settled,
    Loan::Realised,
    Loan::Recovered
  ]

  belongs_to :lender

  has_many :loans

  has_many :loans_using_allocation,
           class_name: "Loan",
           conditions: ["loans.state IN (?)", USAGE_LOAN_STATES]

  validates_presence_of :lender_id, strict: true
  validates_presence_of :allocation, :starts_on, :ends_on

  format :allocation, with: MoneyFormatter.new

  def title
    start_date = starts_on.strftime('%B %Y')
    end_date = ends_on.strftime('%B %Y')
    [start_date, end_date].join(' - ')
  end
end




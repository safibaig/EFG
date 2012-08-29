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
  belongs_to :modified_by, class_name: 'User'

  has_many :loans

  has_many :loans_using_allocation,
           class_name: "Loan",
           conditions: ["loans.state IN (?)", USAGE_LOAN_STATES]

  validates_presence_of :lender_id, strict: true
  validates_presence_of :allocation, :description, :ends_on, :guarantee_rate,
    :premium_rate, :starts_on
  validates_inclusion_of :allocation_type_id, in: [1, 2]

  attr_accessible :allocation, :allocation_type_id, :description, :ends_on,
    :guarantee_rate, :premium_rate, :starts_on

  format :allocation, with: MoneyFormatter.new
  format :ends_on, with: QuickDateFormatter
  format :starts_on, with: QuickDateFormatter

  def allocation_type
    LoanAllocationType.find(allocation_type_id)
  end

  def title
    start_date = starts_on.strftime('%B %Y')
    end_date = ends_on.strftime('%B %Y')
    [start_date, end_date].join(' - ')
  end
end

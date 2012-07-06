class Invoice < ActiveRecord::Base
  include FormatterConcern

  PERIOD_COVERED_QUARTERS = ['March', 'June', 'September', 'December']

  belongs_to :lender
  belongs_to :created_by, class_name: 'User'
  has_many :settled_loans, class_name: 'Loan', foreign_key: 'invoice_id'

  validates :lender, presence: true
  validates :created_by, presence: true, on: :create
  validates :period_covered_quarter, presence: true, inclusion: PERIOD_COVERED_QUARTERS
  validates :period_covered_year, presence: true, format: /\A(\d{4})\Z/
  validates :reference, presence: true
  validates :received_on, presence: true

  format :received_on, with: QuickDateFormatter

  attr_accessible :lender_id, :reference, :period_covered_quarter,
                  :period_covered_year, :received_on, :settled_loan_ids

  def demanded_loans
    lender.loans.demanded
  end

  after_save :transition_loans
  def transition_loans
    raise LoanStateTransition::IncorrectLoanState unless settled_loans.all? {|loan| loan.state == Loan::Demanded }
    settled_loans.update_all(state: Loan::Settled)
  end
end

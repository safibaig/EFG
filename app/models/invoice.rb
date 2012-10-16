class Invoice < ActiveRecord::Base
  include FormatterConcern

  PERIOD_COVERED_QUARTERS = ['March', 'June', 'September', 'December']

  belongs_to :lender
  belongs_to :created_by, class_name: 'User'
  has_many :settled_loans, class_name: 'Loan', foreign_key: 'invoice_id'

  validates :lender_id, presence: true
  validates :created_by, presence: true, on: :create
  validates :period_covered_quarter, presence: true, inclusion: PERIOD_COVERED_QUARTERS
  validates :period_covered_year, presence: true, format: /\A(\d{4})\Z/
  validates :reference, presence: true
  validates :received_on, presence: true
  validate(on: :create) do |invoice|
    if invoice.loans_to_be_settled.none?
      errors.add(:base, 'No loans were selected.')
    end
  end

  format :received_on, with: QuickDateFormatter

  attr_accessible :lender_id, :reference, :period_covered_quarter,
                  :period_covered_year, :received_on, :loans_to_be_settled_ids

  before_create :generate_xref, unless: :xref

  def demanded_loans
    lender.loans.demanded
  end

  def loans_to_be_settled
    @loans_to_be_settled || []
  end

  def loans_to_be_settled_ids=(ids)
    @loans_to_be_settled = Loan.where(id: ids)
  end

  def save_and_settle_loans
    raise LoanStateTransition::IncorrectLoanState unless loans_to_be_settled.all? {|loan| loan.state == Loan::Demanded }

    transaction do
      save!
      settle_loans!
      log_loan_state_change!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private
    def settle_loans!
      loans_to_be_settled.update_all(
        modified_by_id: created_by.id,
        state: Loan::Settled,
        invoice_id: self.id,
        settled_on: Date.today
      )
      self.settled_loans = loans_to_be_settled
    end

    def log_loan_state_change!
      settled_loans.each { |loan| LoanStateChange.log(loan, 18, created_by) }
    end

    def generate_xref
      string = random_xref
      if self.class.exists?(xref: string)
        generate_xref
      else
        self.xref = string
      end
    end

    def random_xref
      6.times.map { |n| (0..9).to_a.sample }.join + '-INV'
    end

end

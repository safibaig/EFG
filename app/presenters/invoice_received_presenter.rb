require 'active_model/model'

class InvoiceReceivedPresenter
  PERIOD_COVERED_QUARTERS = Invoice::PERIOD_COVERED_QUARTERS

  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_reader :invoice
  attr_accessor :lender, :reference, :period_covered_quarter, :period_covered_year, :received_on, :creator

  attr_accessible :lender_id, :reference, :period_covered_quarter,
                  :period_covered_year, :received_on, :loans_to_be_settled_ids

  validates :lender_id, presence: true
  validates :reference, presence: true
  validates :received_on, presence: true
  validates :period_covered_quarter, presence: true, inclusion: PERIOD_COVERED_QUARTERS
  validates :period_covered_year, presence: true, format: /\A(\d{4})\Z/
  validates_presence_of :creator, strict: true, on: :save

  validate(on: :save) do |invoice|
    if invoice.loans_to_be_settled.none?
      errors.add(:base, 'No loans were selected.')
    end
  end

  def self.name
    Invoice.name
  end

  def lender_id
    lender && lender.id
  end

  def lender_id=(id)
    self.lender = Lender.find_by_id(id)
  end

  def received_on=(value)
    @received_on = QuickDateFormatter.parse(value)
  end

  def demanded_loans
    lender.loans.demanded
  end

  def loans_to_be_settled
    @loans_to_be_settled || []
  end

  def loans_to_be_settled_ids=(ids)
    @loans_to_be_settled = lender && lender.loans.where(id: ids)
  end

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def save
    return false if invalid?(:details) || invalid?(:save)

    raise LoanStateTransition::IncorrectLoanState unless loans_to_be_settled.all? {|loan| loan.state == Loan::Demanded }

    ActiveRecord::Base.transaction do
      create_invoice!
      settle_loans!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private
    attr_writer :invoice

    def create_invoice!
      self.invoice = Invoice.create! do |invoice|
        invoice.lender = self.lender
        invoice.reference = self.reference
        invoice.period_covered_quarter = self.period_covered_quarter
        invoice.period_covered_year = self.period_covered_year
        invoice.received_on = self.received_on
        invoice.created_by = self.creator
      end
    end

    def settle_loans!
      loans_to_be_settled.each do |loan|
        loan.state = Loan::Settled
        loan.settled_on = Date.today
        loan.invoice = self.invoice
        loan.modified_by = self.creator
        loan.save!

        LoanStateChange.log(loan, LoanEvent::CreateClaim, self.creator)
      end
    end
end

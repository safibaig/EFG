require 'active_model/model'

class InvoiceReceivedPresenter
  class SettleLoanRow
    attr_reader :loan

    delegate :business_name, :corrected?, :dti_amount_claimed, :dti_demanded_on,
      :id, :persisted?, :reference, :state, :to_key, to: :loan

    def self.model_name
      Loan.model_name
    end

    def initialize(loan)
      @loan = loan
      @settled = false
      @settled_amount = loan.dti_amount_claimed
    end

    attr_accessor :settled, :settled_amount

    def settled?
      settled
    end

    def settled_amount=(value)
      @settled_amount = Money.parse(value)
    end
  end

  PERIOD_COVERED_QUARTERS = Invoice::PERIOD_COVERED_QUARTERS

  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_reader :invoice
  attr_accessor :lender, :reference, :period_covered_quarter, :period_covered_year, :received_on, :creator

  attr_accessible :lender_id, :reference, :period_covered_quarter,
                  :period_covered_year, :received_on, :loans_attributes

  validates :lender_id, presence: true
  validates :reference, presence: true
  validates :received_on, presence: true
  validates :period_covered_quarter, presence: true, inclusion: PERIOD_COVERED_QUARTERS
  validates :period_covered_year, presence: true, format: /\A(\d{4})\Z/
  validates_presence_of :creator, strict: true, on: :save

  validate(on: :save) do |invoice|
    if loans.none? {|loan| loan.settled? }
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

  def loans
    @loans ||= lender.loans.demanded.map {|loan| SettleLoanRow.new(loan) }
  end

  def loans_attributes=(values)
    values.each do |_, attributes|
      loan = loans_by_id[attributes['id'].to_i]
      loan.settled = (attributes['settled'] == '1')
      loan.settled_amount = attributes['settled_amount']
    end
  end

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def save
    return false if invalid?(:details) || invalid?(:save)

    raise LoanStateTransition::IncorrectLoanState unless loans.all? {|loan| loan.state == Loan::Demanded }

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
      loans.select(&:settled?).each do |loan_row|
        loan = loan_row.loan
        loan.state = Loan::Settled
        loan.settled_on = Date.today
        loan.invoice = self.invoice
        loan.modified_by = self.creator
        loan.settled_amount = loan_row.settled_amount
        loan.save!

        LoanStateChange.log(loan, LoanEvent::CreateClaim, self.creator)
      end
    end

    def loans_by_id
      @loans_by_id ||= loans.index_by(&:id)
    end
end

class LoanGuarantee
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Offered, to: Loan::Guaranteed, event: LoanEvent::Guaranteed

  before_save :set_maturity_date
  after_save :create_initial_draw_change!

  attribute :received_declaration
  attribute :signed_direct_debit_received
  attribute :first_pp_received
  attribute :repayment_duration, read_only: true

  attr_reader :initial_draw_date
  attr_accessible :initial_draw_date

  validates_presence_of :initial_draw_date

  validate :initial_draw_date_is_not_before_facility_letter_date, if: :initial_draw_date

  validate :initial_draw_date_is_not_6_months_after_facility_letter_date, if: :initial_draw_date

  validate do
    errors.add(:received_declaration, :accepted) unless self.received_declaration
    errors.add(:signed_direct_debit_received, :accepted) unless self.signed_direct_debit_received
    errors.add(:first_pp_received, :accepted) unless self.first_pp_received
  end

  def initial_draw_amount
    @initial_draw_amount ||= loan.premium_schedule.initial_draw_amount
  end

  def initial_draw_date=(value)
    @initial_draw_date = value.present? ? QuickDateFormatter.parse(value) : nil
  end

  private
    def set_maturity_date
      loan.maturity_date = initial_draw_date.advance(months: loan.repayment_duration.total_months, days: 1)
    end

    def create_initial_draw_change!
      InitialDrawChange.create! do |initial_draw_change|
        initial_draw_change.amount_drawn = initial_draw_amount
        initial_draw_change.created_by = modified_by
        initial_draw_change.date_of_change = initial_draw_date
        initial_draw_change.loan = loan
        initial_draw_change.modified_date = Date.current
      end
    end

    def initial_draw_date_is_not_before_facility_letter_date
      errors.add(:initial_draw_date, :before_facility_date) if initial_draw_date < loan.facility_letter_date
    end

    def initial_draw_date_is_not_6_months_after_facility_letter_date
      if initial_draw_date > loan.facility_letter_date.advance(months: 6)
        errors.add(:initial_draw_date, :too_long_after_facility_date)
      end
    end

end

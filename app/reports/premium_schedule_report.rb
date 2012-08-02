require 'active_model/model'
require 'csv'

class PremiumScheduleReport
  HEADERS = ['Draw Down Date', 'Lender organisation', 'Loan reference',
    'Schedule Type', 'Initial Premium Cheque', '1st Collection Date',
    'No of Payments'] + (1..40).map { |i| "Premium#{i}" }
  LOAN_SCHEMES = ['All', 'SFLG only', 'EFG only']
  LOAN_TYPES = %w(All New Legacy)
  SCHEDULE_TYPES = %w(All New Changed)

  include ActiveModel::Model

  attr_accessor :collection_month, :lender_id, :loan_reference, :loan_scheme,
    :loan_type, :schedule_type
  attr_reader :finish_on, :start_on

  validates_format_of :collection_month, with: /\d+\/\d+/, allow_blank: true
  validate :all_the_things

  def count
    loans.count
  end

  def finish_on=(value)
    @finish_on = QuickDateFormatter.parse(value)
  end

  def lender
    Lender.find(lender_id) if lender_id.present?
  end

  def loans
    scope = Loan.includes(:lender)
    scope = scope.where(lender_id: lender_id) if lender_id.present?
    scope = scope.where(reference: loan_reference) if loan_reference.present?
    scope
  end

  def start_on=(value)
    @start_on = QuickDateFormatter.parse(value)
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADERS

      loans.each do |loan|
        csv << values_from_loan(loan)
      end
    end
  end

  private
    def all_the_things
      return if loan_reference.present?

      if collection_month.blank? && schedule_type != 'New'
        errors.add(:collection_month, :required)
      end

      if finish_on.blank? && start_on.blank? && schedule_type != 'Changed'
        errors.add(:base, :start_or_finish_is_required)
      end
    end

    def values_from_loan(loan)
      [
        nil,                                      # Draw Down Date
        loan.lender.organisation_reference_code,  # Lender organisation
        loan.reference,                           # Loan reference
        nil,                                      # Schedule Type
        nil,                                      # Initial Premium Cheque
        nil,                                      # 1st Collection Date
        nil                                       # No of Payments
      ] + Array.new(40)
    end
end

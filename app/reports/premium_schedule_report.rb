require 'active_model/model'
require 'csv'

class PremiumScheduleReport
  LOAN_SCHEMES = ['All', 'SFLG only', 'EFG only']
  LOAN_TYPES = %w(All New Legacy)
  SCHEDULE_TYPES = %w(All New Changed)

  include ActiveModel::Model

  attr_accessor :collection_month, :lender_id, :loan_reference, :loan_scheme,
    :loan_type, :schedule_type
  attr_reader :finish_on, :start_on

  validates_format_of :collection_month, with: /\A\d+\/\d+\z/, allow_blank: true
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
    scope = Loan
      .select([
        'guaranteed_loan_change.date_of_change AS _guaranteed_date',
        'first_loan_change.date_of_change AS _draw_down_date',
        'loans.*', # TODO: restrict to required columns.
        'lenders.organisation_reference_code AS _lender_organisation',
        'state_aid_calculations.id AS state_aid_calculation_id'
      ].join(', '))
      .joins(:lender)
      .joins('INNER JOIN loan_changes AS guaranteed_loan_change ON guaranteed_loan_change.loan_id = loans.id')
      .joins('INNER JOIN loan_changes AS first_loan_change ON first_loan_change.loan_id = loans.id AND first_loan_change.seq = 0')
      .where(loans: { legacy_small_loan: false })

    max_state_aid_seq = StateAidCalculation.select('MAX(seq)').where('loan_id = loans.id')

    scope = scope
      .joins(:state_aid_calculations)
      .where("state_aid_calculations.seq = (#{max_state_aid_seq.to_sql})")

    if schedule_type.present? && schedule_type != 'All'
      if schedule_type == 'Changed'
        # For a "Changed" loan take the guaranteed date to be the last time it
        # was changed.
        max_change_seq = LoanChange.select('MAX(seq)').where('loan_id = loans.id')
        scope = scope.where("guaranteed_loan_change.seq = (#{max_change_seq.to_sql})")

        calc_type = 'R'
      else
        # Take a "New" loan's guaranteed date from its first change.
        scope = scope.where('guaranteed_loan_change.seq = 0')

        # TODO: Should this actually use date_of_change instead of modified_date?
        scope = scope.where('first_loan_change.modified_date >= ?', start_on)  if start_on
        scope = scope.where('first_loan_change.modified_date <= ?', finish_on) if finish_on

        calc_type = %w(S N)
      end

      scope = scope.where(state_aid_calculations: { calc_type: calc_type })
    end

    if loan_scheme.present? && loan_scheme != 'All'
      scheme = loan_scheme == 'SFLG Only' ? Loan::SFLG_SCHEME : Loan::EFG_SCHEME
      scope = scope.where(loans: { loan_scheme: scheme })
    end

    if loan_type.present? && loan_type != 'All'
      loan_source = loan_type == 'Legacy' ? Loan::LEGACY_SFLG_SOURCE : Loan::SFLG_SOURCE
      scope = scope.where(loans: { loan_source: loan_source })
    end

    scope = scope.where(lender_id: lender_id) if lender_id.present?
    scope = scope.where(reference: loan_reference) if loan_reference.present?
    scope
  end

  def start_on=(value)
    @start_on = QuickDateFormatter.parse(value)
  end

  def to_csv
    CSV.generate do |csv|
      csv << PremiumScheduleReportRow::HEADERS

      PremiumScheduleReportRow.from_loans(loans).each do |row|
        csv << row.to_csv
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
        errors.add(:base, :start_or_finish_required)
      end

      if schedule_type == 'Changed' && (finish_on.present? || start_on.present?)
        errors.add(:base, :start_or_finish_forbidden)
      end
    end
end

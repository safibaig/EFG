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
        'loans.id',
        'loans.reference',
        'loans.premium_rate',
        'loans.lending_limit_id',
        'first_loan_change.date_of_change AS draw_down_date',
        'lenders.organisation_reference_code AS lender_organisation',
        'state_aid_calculations.id AS state_aid_calculation_id'
      ].join(', '))
      .joins(:lender, :state_aid_calculations, :loan_modifications)
      .joins('INNER JOIN loan_modifications AS first_loan_change
                ON first_loan_change.loan_id = loans.id AND first_loan_change.seq = 0')
      .where(loans: { legacy_small_loan: false })
      .where(schedule_type_conditions)

    scope = scope.where(lender_id: lender_id) if lender_id.present?
    scope = scope.where(reference: loan_reference) if loan_reference.present?

    if loan_scheme.present? && loan_scheme != 'All'
      scheme = loan_scheme =~ /SFLG/ ? Loan::SFLG_SCHEME : Loan::EFG_SCHEME
      scope = scope.where(loans: { loan_scheme: scheme })
    end

    if loan_type.present? && loan_type != 'All'
      loan_source = loan_type == 'Legacy' ? Loan::LEGACY_SFLG_SOURCE : Loan::SFLG_SOURCE
      scope = scope.where(loans: { loan_source: loan_source })
    end

    scope
  end

  def start_on=(value)
    @start_on = QuickDateFormatter.parse(value)
  end

  def to_csv
    CSV.generate do |csv|
      csv << PremiumScheduleReportRow::HEADERS

      PremiumScheduleReportRow.from_loans(loans).each do |row|
        begin
          csv << row.to_csv

        # We've seen ZeroDivisionError in production and want to understand more details about the loan in question.
        rescue StandardError => e
          Rails.logger.error("#{self.class} Error: #{e.to_s} reporting on #{row.loan.inspect}")
        end
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

      if schedule_type == 'New' && collection_month.present?
        errors.add(:base, :collection_month_forbidden)
      end
    end

    def schedule_type_conditions
      conditions = []

      if %w(All New).include?(schedule_type)
        max_state_aid_seq = StateAidCalculation.
                              select("max(seq)").
                              where("loans.id = state_aid_calculations.loan_id").
                              where("calc_type = 'S' OR calc_type = 'N'")

        if start_on
          max_state_aid_seq = max_state_aid_seq.where("loan_modifications.modified_date >= ?", start_on)
        end

        if finish_on
          max_state_aid_seq = max_state_aid_seq.where("loan_modifications.modified_date <= ?", finish_on)
        end

        conditions << Loan
          .where("(state_aid_calculations.calc_type = 'S' or state_aid_calculations.calc_type = 'N')")
          .where('loan_modifications.seq = 0')
          .where("state_aid_calculations.seq = (#{max_state_aid_seq.to_sql})")
          .where_values
          .join(" AND ")
      end

      if %w(All Changed).include?(schedule_type)
        max_state_aid_seq = StateAidCalculation.
                              select("max(seq)").
                              where("loans.id = state_aid_calculations.loan_id").
                              where("calc_type = 'R'")

        if collection_month
          max_state_aid_seq = max_state_aid_seq.where(premium_cheque_month: collection_month)
        end

        max_loan_change_seq = LoanModification.select('max(seq)').where('loan_modifications.loan_id = loans.id')

        conditions << Loan
          .where("state_aid_calculations.calc_type = 'R'")
          .where("loan_modifications.seq = (#{max_loan_change_seq.to_sql})")
          .where("state_aid_calculations.seq = (#{max_state_aid_seq.to_sql})")
          .where_values
          .join(" AND ")
      end

      conditions.map { |condition| "(#{condition})" }.join(" OR ")
    end
end

class PremiumScheduleReportRow
  HEADERS = ['Draw Down Date', 'Lender organisation', 'Loan reference',
    'Schedule Type', 'Initial Premium Cheque', '1st Collection Date',
    'No of Payments'] + (1..40).map { |i| "Premium#{i}" }

  attr_accessor :loan, :premium_schedule

  def self.from_loans(loans)
    premium_schedule_ids = loans.map(&:premium_schedule_id)
    premium_schedules = PremiumSchedule.find(premium_schedule_ids)
    premium_schedule_lookup = premium_schedules.index_by { |s| "#{s.loan_id}_#{s.calc_type}" }

    loans.map do |loan|
      new(loan).tap do |row|
        key = "#{loan.id}_#{loan.premium_schedule_calc_type}"
        row.premium_schedule = premium_schedule_lookup[key]
      end
    end
  end

  def initialize(loan)
    @loan = loan
  end

  def to_csv
    [
      loan.draw_down_date.strftime('%d-%m-%Y'),
      loan.lender_organisation,
      loan.reference,
      calc_type,
      premium_schedule.initial_premium_cheque.to_f,
      first_collection_month,
      premium_schedule.number_of_subsequent_payments,
    ] + premiums
  end

  private

  def premiums
    array = premium_schedule.subsequent_premiums.map(&:to_f)
    array.unshift(0.0) unless premium_schedule.reschedule?
    array
  end

  # always display calc_type 'N' as 'S' in this report
  def calc_type
    if loan.premium_schedule_calc_type == PremiumSchedule::NOTIFIED_AID_TYPE
      PremiumSchedule::SCHEDULE_TYPE
    else
      loan.premium_schedule_calc_type
    end
  end

  def first_collection_month
    if premium_schedule.premium_cheque_month.present?
      premium_schedule.premium_cheque_month
    else
      loan.draw_down_date.advance(months: 3).strftime('%m/%Y')
    end
  end

end

class PremiumScheduleReportRow
  HEADERS = ['Draw Down Date', 'Lender organisation', 'Loan reference',
    'Schedule Type', 'Initial Premium Cheque', '1st Collection Date',
    'No of Payments'] + (1..40).map { |i| "Premium#{i}" }

  attr_accessor :loan, :state_aid_calculation

  def self.from_loans(loans)
    state_aid_calculation_ids = loans.map(&:state_aid_calculation_id)
    state_aid_calculations = StateAidCalculation.find(state_aid_calculation_ids)
    state_aid_calculation_lookup = state_aid_calculations.index_by { |s| "#{s.loan_id}_#{s.calc_type}" }

    loans.map do |loan|
      new(loan).tap do |row|
        key = "#{loan.id}_#{loan.state_aid_calculation_calc_type}"
        row.state_aid_calculation = state_aid_calculation_lookup[key]
      end
    end
  end

  def initialize(loan)
    @loan = loan
  end

  def premium_schedule_generator
    @premium_schedule_generator ||= PremiumScheduleGenerator.new(state_aid_calculation, loan)
  end

  def to_csv
    [
      loan.draw_down_date.strftime('%d-%m-%Y'),
      loan.lender_organisation,
      loan.reference,
      calc_type,
      premium_schedule_generator.initial_premium_cheque.to_f,
      first_collection_month,
      premium_schedule_generator.number_of_subsequent_payments,
    ] + premiums
  end

  private

  def premiums
    array = premium_schedule_generator.subsequent_premiums.map(&:to_f)
    array.unshift(0.0) unless premium_schedule_generator.reschedule?
    array
  end

  # always display calc_type 'N' as 'S' in this report
  def calc_type
    if loan.state_aid_calculation_calc_type == StateAidCalculation::NOTIFIED_AID_TYPE
      StateAidCalculation::SCHEDULE_TYPE
    else
      loan.state_aid_calculation_calc_type
    end
  end

  def first_collection_month
    if state_aid_calculation.premium_cheque_month.present?
      state_aid_calculation.premium_cheque_month
    else
      loan.draw_down_date.advance(months: 3).strftime('%m/%Y')
    end
  end

end

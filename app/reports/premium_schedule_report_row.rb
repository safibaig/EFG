class PremiumScheduleReportRow
  HEADERS = ['Draw Down Date', 'Lender organisation', 'Loan reference',
    'Schedule Type', 'Initial Premium Cheque', '1st Collection Date',
    'No of Payments'] + (1..40).map { |i| "Premium#{i}" }

  attr_accessor :loan, :state_aid_calculation

  def self.from_loans(loans)
    state_aid_calculation_ids = loans.map(&:state_aid_calculation_id)
    state_aid_calculations = StateAidCalculation.find(state_aid_calculation_ids)
    state_aid_calculation_lookup = state_aid_calculations.index_by(&:loan_id)

    loans.map do |loan|
      new(loan).tap do |row|
        row.state_aid_calculation = state_aid_calculation_lookup[loan.id]
      end
    end
  end

  def initialize(loan)
    @loan = loan
  end

  def premium_schedule
    @premium_schedule ||= PremiumSchedule.new(state_aid_calculation, loan)
  end

  def to_csv
    [
      loan._draw_down_date.strftime('%d-%m-%Y'),
      loan._lender_organisation,
      loan.reference,
      state_aid_calculation.calc_type,
      premium_schedule.premiums.first.to_f,
      state_aid_calculation.premium_cheque_month,
      premium_schedule.number_of_payments,
      0.0 # TODO: Zero? Really?
    ] + premium_schedule.subsequent_premiums.map(&:to_f)
  end
end

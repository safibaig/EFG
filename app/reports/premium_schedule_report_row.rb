class PremiumScheduleReportRow
  HEADERS = ['Draw Down Date', 'Lender organisation', 'Loan reference',
    'Schedule Type', 'Initial Premium Cheque', '1st Collection Date',
    'No of Payments'] + (1..40).map { |i| "Premium#{i}" }

  attr_accessor :loan

  def self.from_loans(loans)
    loans.map do |loan|
      new(loan)
    end
  end

  def initialize(loan)
    @loan = loan
  end

  def to_csv
    [
      loan._draw_down_date.strftime('%d-%m-%Y'),
      loan._lender_organisation,
      loan.reference,
      loan.state_aid_calculations.last.calc_type,
      nil,  # Initial Premium Cheque
      nil,  # 1st Collection Date
      nil   # No of Payments
    ] + Array.new(40)
  end
end

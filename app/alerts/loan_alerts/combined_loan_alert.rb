class LoanAlerts::CombinedLoanAlert
  def initialize(alert1, alert2)
    raise ArgumentError, 'alerts must have matching date_method' unless alert1.date_method == alert2.date_method

    @alerts = [alert1, alert2]
  end

  attr_reader :alerts

  def start_date
    @start_date ||= alerts.map(&:start_date).min
  end

  def end_date
    @end_date ||= alerts.map(&:end_date).max
  end

  def date_method
    @date_method ||= alerts.first.date_method
  end

  def loans
    alerts.map(&:loans).flatten.sort_by(&date_method)
  end
end

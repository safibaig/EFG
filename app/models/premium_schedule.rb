class PremiumSchedule

  def initialize(state_aid_calculation, loan)
    @state_aid_calculation = state_aid_calculation
    @loan = loan
  end

  attr_reader :loan, :state_aid_calculation

  delegate :initial_draw_year, to: :state_aid_calculation
  delegate :initial_draw_amount, to: :state_aid_calculation
  delegate :initial_draw_months, to: :state_aid_calculation
  delegate :initial_capital_repayment_holiday, to: :state_aid_calculation
  delegate :second_draw_amount, to: :state_aid_calculation
  delegate :second_draw_months, to: :state_aid_calculation
  delegate :third_draw_amount, to: :state_aid_calculation
  delegate :third_draw_months, to: :state_aid_calculation
  delegate :fourth_draw_amount, to: :state_aid_calculation
  delegate :fourth_draw_months, to: :state_aid_calculation
  delegate :reschedule?, to: :state_aid_calculation
  delegate :premium_cheque_month, to: :state_aid_calculation
  delegate :premium_rate, to: :loan

  def initial_draw_date
    loan.initial_draw_change.try :date_of_change
  end

  def number_of_subsequent_payments
    subsequent_premiums.count { |amount|
      amount > 0
    }
  end

  def premiums
    return @premiums if @premiums
    @premiums = Array.new(40) do |quarter|
      PremiumScheduleQuarter.new(quarter, total_quarters, self).premium_amount
    end
  end

  def subsequent_premiums
    @subsequent_premiums ||= reschedule? ? premiums : premiums[1..-1]
  end

  def total_subsequent_premiums
    subsequent_premiums.sum
  end

  def total_premiums
    premiums.sum
  end

  # This returns a string because its not really a valid date and it doesn't
  # have a day. We could just pick an arbitary day, but then it might be
  # tempting to (incorrectly) format it in the view with the day shown.
  def second_premium_collection_month
    return unless initial_draw_date
    initial_draw_date.advance(months: 3).strftime('%m/%Y')
  end

  # TODO: round total quarter up.
  # The legacy system rounded down which excludes the last quarter from the premium schedule.
  # This is a bug as the last quarter should be in the schedule, but we are replicating it
  # for now for data consistency.
  def total_quarters
    @total_quarters ||= begin
      months = initial_draw_months / 3
      months = 1 if months.zero?
      months
    end
  end

  def initial_premium_cheque
    reschedule? ? Money.new(0) : premiums.first
  end

end

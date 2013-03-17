class PremiumScheduleGenerator

  def initialize(premium_schedule, loan)
    @premium_schedule = premium_schedule
    @loan = loan
  end

  attr_reader :loan, :premium_schedule

  delegate :initial_draw_year, to: :premium_schedule
  delegate :initial_draw_amount, to: :premium_schedule
  delegate :repayment_duration, to: :premium_schedule
  delegate :initial_capital_repayment_holiday, to: :premium_schedule
  delegate :second_draw_amount, to: :premium_schedule
  delegate :second_draw_months, to: :premium_schedule
  delegate :third_draw_amount, to: :premium_schedule
  delegate :third_draw_months, to: :premium_schedule
  delegate :fourth_draw_amount, to: :premium_schedule
  delegate :fourth_draw_months, to: :premium_schedule
  delegate :reschedule?, to: :premium_schedule
  delegate :premium_cheque_month, to: :premium_schedule
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
    klass = case @loan.repayment_frequency
      when RepaymentFrequency::Annually
        # TODO: fixme:
        LegacyQuarterlyPremiumPaymentCollection
      when RepaymentFrequency::SixMonthly
        # TODO: fixme:
        LegacyQuarterlyPremiumPaymentCollection
      when RepaymentFrequency::Quarterly
        LegacyQuarterlyPremiumPaymentCollection
      when RepaymentFrequency::Monthly
        # TODO: fixme:
        LegacyQuarterlyPremiumPaymentCollection
      when RepaymentFrequency::InterestOnly
        InterestOnlyPremiumPaymentCollection
      else
        raise ArgumentError, 'unknown repayment frequency type'
      end

    klass.new(premium_schedule).to_a
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

  def initial_premium_cheque
    reschedule? ? Money.new(0) : premiums.first
  end

end

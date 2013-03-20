class LegacyQuarterlyPremiumPaymentCollection < QuarterlyPremiumPaymentCollection
  # The legacy system rounded down which excludes the last quarter from the premium schedule.
  # This is a bug as the last quarter should be in the schedule, but we are replicating it
  # for now for data consistency.
  def number_of_quarters
    @number_of_quarters ||= begin
      quarters = premium_schedule.repayment_duration / 3
      quarters = 1 if quarters.zero?
      quarters
    end
  end
end

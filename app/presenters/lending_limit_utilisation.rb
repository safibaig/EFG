class LendingLimitUtilisation
  PHASE_3_BOUNDARY = Money.new(1_000_000_00)
  PHASE_3_FIRST_MILLION_PERCENT = 0.15
  PHASE_3_POST_MILLION_PERCENT = 0.09225
  PHASE_3_FIRST_MILLION_CAP = PHASE_3_BOUNDARY * PHASE_3_FIRST_MILLION_PERCENT

  attr_reader :lending_limit

  def initialize(lending_limit)
    @lending_limit = lending_limit
  end

  delegate :name, to: :lending_limit
  delegate :allocation, to: :lending_limit

  def loans
    lending_limit.loans_using_lending_limit
  end

  def usage_amount
    @usage_amount ||= Money.new(loans.sum(:amount))
  end

  def usage_percentage
    percentage(usage_amount, allocation)
  end

  def cumulative_claims
    @cumulative_claims ||= Money.new(loans.sum(:amount_demanded))
  end

  def gross_utilisation_of_claim_limit
    percentage(cumulative_claims, claim_cap)
  end

  def cumulative_net_claims
    @cumulative_net_claims ||= begin
      loan_ids = loans.pluck(:id)

      pence = if loan_ids.any?
        Recovery.where(loan_id: loan_ids).sum(:amount_due_to_dti)
      else
        0
      end

      cumulative_claims - Money.new(pence)
    end
  end

  def net_utilisation_of_claim_limit
    percentage(cumulative_net_claims, claim_cap)
  end

  private
    def claim_cap
      if usage_amount > PHASE_3_BOUNDARY
        PHASE_3_FIRST_MILLION_CAP + ((usage_amount - PHASE_3_BOUNDARY) * PHASE_3_POST_MILLION_PERCENT)
      else
        usage_amount * PHASE_3_FIRST_MILLION_PERCENT
      end
    end

    def percentage(value, total)
      number = value.zero? ? 0 : (value / total) * 100
      sprintf '%.2f%', number
    end
end

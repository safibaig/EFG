module GovernmentGuaranteeClaimCalculation
  extend ActiveSupport::Concern

  def calculate_dti_amount_claimed(loan)
    interest           = loan.dti_interest || Money.new(0)
    break_costs        = loan.dti_break_costs || Money.new(0)
    demand_outstanding = loan.dti_demand_outstanding || Money.new(0)

    if loan.sflg?
      loan.dti_amount_claimed = (demand_outstanding + interest + break_costs) * loan.guarantee_rate / 100
    else
      loan.dti_amount_claimed = demand_outstanding * loan.guarantee_rate / 100
    end
  end

end
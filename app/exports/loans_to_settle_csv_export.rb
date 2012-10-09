class LoansToSettleCsvExport < BaseCsvExport

  private

  def fields
    %w(
      reference
      business_name
      dti_demanded_on
      dti_demand_outstanding
      dti_interest
      dti_amount_claimed
    )
  end

end
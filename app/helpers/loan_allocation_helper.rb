module LoanAllocationHelper

  # FIXME - use loan_allocation for the current date or date when loan first created?
  def loan_allocation_options_for_select(lender)
    [
      [lender.name, lender.lending_limits.last.id]
    ]
  end

end

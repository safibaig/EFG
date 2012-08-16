class LoanReportCsvRow

  def initialize(loan)
    @loan = loan
  end

  # TODO - add DED table data
  # TODO - add a loan's modified by user ID
  def row
    [
      @loan.reference,
      @loan.legal_form.try(:name),
      @loan.postcode,
      @loan.non_validated_postcode,
      @loan.town,
      @loan.turnover.to_s,
      @loan.trading_date.try(:strftime, '%d-%m-%Y'),
      @loan.sic_code,
      @loan.sic_desc,
      @loan.sic_parent_desc,
      @loan.reason.try(:name),
      @loan.amount.to_s,
      @loan.guarantee_rate.to_s,
      @loan.premium_rate.to_s,
      @loan._loan_allocation_description,
      @loan._lender_organisation_reference_code,
      @loan.state,
      @loan.repayment_duration.try(:total_months),
      @loan.repayment_frequency.try(:name),
      @loan.maturity_date.try(:strftime, '%d-%m-%Y'),
      @loan.generic1,
      @loan.generic2,
      @loan.generic3,
      @loan.generic4,
      @loan.generic5,
      @loan.cancelled_reason.try(:name),
      @loan.cancelled_comment,
      @loan.cancelled_on.try(:strftime, '%d-%m-%Y'),
      @loan.facility_letter_date.try(:strftime, '%d-%m-%Y'),
      @loan.initial_draw_value.to_s,
      @loan.initial_draw_date.try(:strftime, '%d-%m-%Y'),
      @loan.borrower_demanded_on.try(:strftime, '%d-%m-%Y'),
      @loan.amount_demanded,
      @loan.repaid_on.try(:strftime, '%d-%m-%Y'),
      @loan.no_claim_on.try(:strftime, '%d-%m-%Y'),
      @loan.dti_demanded_on.try(:strftime, '%d-%m-%Y'),
      @loan.dti_demand_outstanding.to_s,
      @loan.dti_amount_claimed.to_s,
      @loan.dti_interest,
      '', # @loan.ded.group_description,
      '', # @loan.ded.category_description,
      '', # @loan.ded.code_description,
      '', # @loan.ded.code,
      @loan.dti_reason,
      @loan.dit_break_costs.to_s,
      @loan._last_recovery_on ? @loan._last_recovery_on.strftime('%d-%m-%Y') : '',
      @loan._total_recoveries ? Money.new(@loan._total_recoveries).to_s : '',
      @loan._last_realisation_at ? @loan._last_realisation_at.strftime('%d-%m-%Y') : '',
      @loan._total_loan_realisations ? Money.new(@loan._total_loan_realisations).to_s : '',
      @loan._total_amount_drawn ? Money.new(@loan._total_amount_drawn).to_s : '',
      @loan._total_lump_sum_repayment ? Money.new(@loan._total_lump_sum_repayment).to_s : '',
      @loan.created_by_id,
      @loan.created_at.try(:strftime, "%d-%m-%Y %I:%M %p"),
      '',# @loan.modified_by_id,
      @loan.updated_at.try(:strftime, '%d-%m-%Y'),
      @loan.remove_guarantee_on.try(:strftime, '%d-%m-%Y'),
      @loan.remove_guarantee_outstanding_amount.to_s,
      @loan.remove_guarantee_reason,
      @loan.state_aid.to_s, # if SIC is notified aid output 'not applicable'
      @loan.settled_on.try(:strftime, '%d-%m-%Y'),
      @loan.invoice.try(:reference),
      @loan.loan_category.try(:name),
      @loan.interest_rate_type.try(:name),
      @loan.interest_rate,
      @loan.fees.to_s,
      boolean_as_text(@loan.private_residence_charge_required),
      boolean_as_text(@loan.personal_guarantee_required),
      @loan.security_proportion,
      @loan.current_refinanced_value.to_s,
      @loan.final_refinanced_value.to_s,
      @loan.original_overdraft_proportion,
      @loan.loan_security_types.collect(&:name).join(' / '),
      @loan.refinance_security_proportion,
      @loan.overdraft_limit.to_s,
      boolean_as_text(@loan.overdraft_maintained),
      @loan.invoice_discount_limit.to_s,
      @loan.debtor_book_coverage,
      @loan.debtor_book_topup
    ]
  end

  private

  def boolean_as_text(bool)
    bool == true ? 'Yes' : 'No'
  end

end
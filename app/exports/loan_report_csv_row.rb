class LoanReportCsvRow
  attr_reader :loan_security_types

  def initialize(loan, loan_security_types)
    @loan = loan
    @loan_security_types = loan_security_types
  end

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
      (@loan.loan_guarantee_rate || @loan.lending_limit_guarantee_rate).to_s,
      (@loan.loan_premium_rate || @loan.lending_limit_premium_rate).to_s,
      @loan.lending_limit_name,
      @loan.lender_organisation_reference_code,
      humanized_state(@loan.state),
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
      @loan.initial_draw_amount ? Money.new(@loan.initial_draw_amount) : '',
      @loan.initial_draw_date.try(:strftime, '%d-%m-%Y'),
      @loan.borrower_demanded_on.try(:strftime, '%d-%m-%Y'),
      @loan.amount_demanded,
      @loan.repaid_on.try(:strftime, '%d-%m-%Y'),
      @loan.no_claim_on.try(:strftime, '%d-%m-%Y'),
      @loan.dti_demanded_on.try(:strftime, '%d-%m-%Y'),
      @loan.dti_demand_outstanding.to_s,
      @loan.dti_amount_claimed.to_s,
      @loan.dti_interest,
      @loan.ded_code_group_description,
      @loan.ded_code_category_description,
      @loan.ded_code_code_description,
      @loan.ded_code_code,
      @loan.dti_reason,
      @loan.dti_break_costs.to_s,
      @loan.last_recovery_on ? @loan.last_recovery_on.strftime('%d-%m-%Y') : '',
      @loan.total_recoveries ? Money.new(@loan.total_recoveries).to_s : '',
      @loan.last_realisation_at ? @loan.last_realisation_at.strftime('%d-%m-%Y') : '',
      @loan.total_loan_realisations ? Money.new(@loan.total_loan_realisations).to_s : '',
      @loan.total_amount_drawn ? Money.new(@loan.total_amount_drawn).to_s : '',
      @loan.total_lump_sum_repayment ? Money.new(@loan.total_lump_sum_repayment).to_s : '',
      @loan.created_by_id,
      @loan.created_at.try(:strftime, "%d-%m-%Y %I:%M %p"),
      @loan.modified_by_id,
      @loan.updated_at.try(:strftime, '%d-%m-%Y'),
      @loan.remove_guarantee_on.try(:strftime, '%d-%m-%Y'),
      @loan.remove_guarantee_outstanding_amount.to_s,
      @loan.remove_guarantee_reason,
      @loan.state_aid.to_s, # if SIC is notified aid output 'not applicable'
      @loan.settled_on.try(:strftime, '%d-%m-%Y'),
      @loan.invoice_reference,
      @loan.loan_category.try(:name),
      @loan.interest_rate_type.try(:name),
      @loan.interest_rate,
      @loan.fees.to_s,
      boolean_as_text(@loan.private_residence_charge_required),
      boolean_as_text(@loan.personal_guarantee_required),
      @loan.security_proportion,
      @loan.current_refinanced_amount.to_s,
      @loan.final_refinanced_amount.to_s,
      @loan.original_overdraft_proportion,
      loan_security_types.collect(&:name).join(' / '),
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

  def humanized_state(state)
    LoanStateFormatter.humanize(state)
  end

end
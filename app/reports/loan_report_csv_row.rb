class LoanReportCsvRow

  def initialize(loan)
    @loan = loan
  end

  def self.header
    %w(
      loan_reference
      legal_form
      post_code
      non_validated_post_code
      town
      annual_turnover
      trading_date
      sic_code
      sic_code_description
      parent_sic_code_description
      purpose_of_loan
      facility_amount
      guarantee_rate
      premium_rate
      lending_limit
      lender_reference
      loan_state
      loan_term
      repayment_frequency
      maturity_date
      generic1
      generic2
      generic3
      generic4
      generic5
      cancellation_reason
      cancellation_comment
      cancellation_date
      scheme_facility_letter_date
      initial_draw_amount
      initial_draw_date
      lender_demand_date
      lender_demand_amount
      repaid_date
      no_claim_date
      demand_made_date
      outstanding_facility_principal
      total_claimed
      outstanding_facility_interest
      business_failure_group
      business_failure_category_description
      business_failure_description
      business_failure_code
      government_demand_reason
      break_cost
      latest_recovery_date
      total_recovered
      latest_realised_date
      total_realised
      cumulative_amount_drawn
      total_lump_sum_repayments
      created_by
      created_at
      modified_by
      modified_date
      guarantee_remove_date
      outstanding_balance
      guarantee_remove_reason
      state_aid_amount
      settled_date
      invoice_reference
      loan_category
      interest_type
      interest_rate
      fees
      type_a1
      type_a2
      type_b1
      type_d1
      type_d2
      type_c1
      security_type
      type_c_d1
      type_e1
      type_e2
      type_f1
      type_f2
      type_f3
    ).collect { |field| t(field) }
  end

  # TODO - add DED table data
  # TODO - add invoice to loan
  # TODO - add lender organisation_reference_code
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
      @loan.guarantee_rate,
      @loan.premium_rate,
      @loan.loan_allocation.try(:description),
      '', # @loan.lender.try(:organisation_reference_code),
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
      @loan.recoveries.last.try(:recovered_on).try(:strftime, '%d-%m-%Y'),
      Money.new(@loan.recoveries.sum(:amount_due_to_dti)).to_s,
      @loan.loan_realisations.last.try(:created_at).try(:strftime, '%d-%m-%Y'),
      Money.new(@loan.loan_realisations.sum(:realised_amount)).to_s,
      Money.new(@loan.loan_changes.sum(:amount_drawn)).to_s,
      Money.new(@loan.loan_changes.sum(:lump_sum_repayment)).to_s,
      @loan.created_by.try(:name),
      @loan.created_at.strftime("%d-%m-%Y %I:%M %p"),
      @loan.modified_by.try(:name),
      @loan.updated_at.try(:strftime, '%d-%m-%Y'),
      @loan.remove_guarantee_on.try(:strftime, '%d-%m-%Y'),
      @loan.remove_guarantee_outstanding_amount.to_s,
      @loan.remove_guarantee_reason,
      @loan.state_aid.to_s, # if SIC is notified aid output 'not applicable'
      @loan.settled_on.try(:strftime, '%d-%m-%Y'),
      '', # @loan.invoice.try(:reference), # need to import legacy references
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

  def self.t(key)
    I18n.t(key, scope: 'csv_headers.loan_report')
  end

  def boolean_as_text(bool)
    bool == true ? 'Yes' : 'No'
  end

end
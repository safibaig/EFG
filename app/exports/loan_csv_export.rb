class LoanCsvExport < BaseCsvExport

  private

  def formats
    {
      ActiveSupport::TimeWithZone => ->(time) { time.strftime('%d/%m/%Y %H:%M:%S') },
      CancelReason => :name.to_proc,
      CfeUser => :name.to_proc,
      Date => ->(date) { date.strftime('%d/%m/%Y') },
      FalseClass => 'No',
      InterestRateType => :name.to_proc,
      LegalForm => :name.to_proc,
      Lender => :name.to_proc,
      LenderUser => :name.to_proc,
      LoanAllocation => :title.to_proc,
      LoanCategory => :name.to_proc,
      LoanReason => :name.to_proc,
      Money => :to_s.to_proc,
      MonthDuration => :total_months.to_proc,
      NilClass => '',
      RepaymentFrequency => :name.to_proc,
      TrueClass => 'Yes',
      Loan => :reference.to_proc
    }
  end

  def fields
    %w(
      reference
      amount
      amount_demanded
      borrower_demand_outstanding
      borrower_demanded_on
      branch_sortcode
      business_name
      business_type
      cancelled_comment
      cancelled_on
      cancelled_reason
      collateral_exhausted
      company_registration
      created_at
      created_by
      current_refinanced_value
      debtor_book_coverage
      debtor_book_topup
      declaration_signed
      dit_break_costs
      dti_amount_claimed
      dti_ded_code
      dti_demand_outstanding
      dti_demanded_on
      dti_interest
      dti_reason
      facility_letter_date
      facility_letter_sent
      fees
      final_refinanced_value
      first_pp_received
      generic1
      generic2
      generic3
      generic4
      generic5
      guarantee_rate
      guaranteed_on
      initial_draw_date
      initial_draw_value
      interest_rate
      interest_rate_type
      invoice_discount_limit
      legacy_small_loan
      legal_form
      lender
      loan_allocation
      loan_category
      loan_scheme
      loan_source
      maturity_date
      next_borrower_demand_seq
      next_change_history_seq
      next_in_calc_seq
      next_in_realise_seq
      next_in_recover_seq
      no_claim_on
      non_val_postcode
      non_validated_postcode
      notified_aid
      original_overdraft_proportion
      outstanding_amount
      overdraft_limit
      overdraft_maintained
      payment_period
      personal_guarantee_required
      postcode
      premium_rate
      previous_borrowing
      private_residence_charge_required
      realised_money_date
      reason
      received_declaration
      recovery_on
      refinance_security_proportion
      remove_guarantee_on
      remove_guarantee_outstanding_amount
      remove_guarantee_reason
      repaid_on
      repayment_duration
      repayment_frequency
      security_proportion
      settled_on
      sic_code
      sic_desc
      sic_eligible
      sic_notified_aid
      sic_parent_desc
      signed_direct_debit_received
      standard_cap
      state
      state_aid
      state_aid_is_valid
      town
      trading_date
      trading_name
      transferred_from
      turnover
      updated_at
      viable_proposition
      would_you_lend
    )
  end

end
class LoanReportCsvExport < BaseCsvExport
  def self.translation_scope
    'csv_headers.loan_report'
  end

  def fields
    [
      :loan_reference,
      :legal_form,
      :post_code,
      :non_validated_post_code,
      :town,
      :annual_turnover,
      :trading_date,
      :sic_code,
      :sic_code_description,
      :parent_sic_code_description,
      :purpose_of_loan,
      :facility_amount,
      :guarantee_rate,
      :premium_rate,
      :lending_limit,
      :lender_reference,
      :loan_state,
      :loan_term,
      :repayment_frequency,
      :maturity_date,
      :generic1,
      :generic2,
      :generic3,
      :generic4,
      :generic5,
      :cancellation_reason,
      :cancellation_comment,
      :cancellation_date,
      :scheme_facility_letter_date,
      :initial_draw_amount,
      :initial_draw_date,
      :lender_demand_date,
      :lender_demand_amount,
      :repaid_date,
      :no_claim_date,
      :demand_made_date,
      :outstanding_facility_principal,
      :total_claimed,
      :outstanding_facility_interest,
      :business_failure_group,
      :business_failure_category_description,
      :business_failure_description,
      :business_failure_code,
      :government_demand_reason,
      :break_cost,
      :latest_recovery_date,
      :total_recovered,
      :latest_realised_date,
      :total_realised,
      :cumulative_amount_drawn,
      :total_lump_sum_repayments,
      :created_by,
      :created_at,
      :modified_by,
      :modified_date,
      :guarantee_remove_date,
      :outstanding_balance,
      :guarantee_remove_reason,
      :state_aid_amount,
      :settled_date,
      :invoice_reference,
      :loan_category,
      :interest_type,
      :interest_rate,
      :fees,
      :type_a1,
      :type_a2,
      :type_b1,
      :type_d1,
      :type_d2,
      :type_c1,
      :security_type,
      :type_c_d1,
      :type_e1,
      :type_e2,
      :type_f1,
      :type_f2,
      :type_f3,
    ]
  end

  private

  def csv_row(row, loan_securities)
    LoanReportCsvRow.new(row, loan_securities)
  end

  def loan_security_types_lookup_for_loan_ids(loan_ids)
    lookup = Hash.new {|hash, key| hash[key] = []}

    LoanSecurity.where(loan_id: loan_ids).each_with_object(lookup) do |loan_security, memo|
      memo[loan_security.loan_id] << loan_security.loan_security_type
    end
  end

  def each_record(&block)
    # Eager load the records so we can create the lookup for the loan_security_types.
    @records.find_in_batches do |batch|
      loan_ids = batch.map {|row| row['id']}
      loan_securities_lookup = loan_security_types_lookup_for_loan_ids(loan_ids)

      batch.each do |record|
        loan_securities = loan_securities_lookup[record['id']]
        block.call(record, loan_securities)
      end
    end
  end
end

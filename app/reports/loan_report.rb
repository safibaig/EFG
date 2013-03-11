class LoanReport
  attr_accessor :states, :loan_sources, :loan_scheme, :lender_ids, :created_by_id,
              :facility_letter_start_date, :facility_letter_end_date,
              :created_at_start_date, :created_at_end_date,
              :last_modified_start_date, :last_modified_end_date

  def loans
    scope = Loan.select(
      [
        'ded_codes.group_description AS ded_code_group_description',
        'ded_codes.category_description AS ded_code_category_description',
        'ded_codes.code_description AS ded_code_code_description',
        'ded_codes.code AS ded_code_code',
        'initial_draw_change.date_of_change AS initial_draw_date',
        'initial_draw_change.amount_drawn AS initial_draw_amount',
        'invoices.reference AS invoice_reference',
        'lending_limits.name AS lending_limit_name',
        'lending_limits.guarantee_rate AS lending_limit_guarantee_rate',
        'lending_limits.premium_rate AS lending_limit_premium_rate',
        'loans.*',
        'loans.guarantee_rate AS loan_guarantee_rate',
        'loans.premium_rate AS loan_premium_rate',
        'created_by_user.username AS created_by_username',
        'modified_by_user.username AS modified_by_username',
        '(SELECT organisation_reference_code FROM lenders WHERE id = loans.lender_id) AS lender_organisation_reference_code',
        '(SELECT recovered_on FROM recoveries WHERE loan_id = loans.id ORDER BY recoveries.id DESC LIMIT 1) AS last_recovery_on',
        '(SELECT SUM(amount_due_to_dti) FROM recoveries WHERE loan_id = loans.id) AS total_recoveries',
        '(SELECT created_at FROM loan_realisations WHERE realised_loan_id = loans.id ORDER BY loan_realisations.id DESC LIMIT 1) AS last_realisation_at',
        '(SELECT SUM(realised_amount) FROM loan_realisations WHERE realised_loan_id = loans.id) AS total_loan_realisations',
        '(SELECT SUM(amount_drawn) FROM loan_modifications WHERE loan_id = loans.id) AS total_amount_drawn',
        '(SELECT SUM(lump_sum_repayment) FROM loan_modifications WHERE loan_id = loans.id) AS total_lump_sum_repayment'
      ].join(',')
    )

    scope = scope.where('loans.state IN (?)', states) if states.present?
    scope = scope.where('loans.loan_source IN (?)', loan_sources) if loan_sources.present?
    scope = scope.where('loans.loan_scheme = ?', loan_scheme) if loan_scheme.present?
    scope = scope.where('loans.lender_id IN (?)', lender_ids) if lender_ids.present?
    scope = scope.where('loans.created_by_id = ?', created_by_id) if created_by_id.present?
    scope = scope.where('loans.facility_letter_date >= ?', facility_letter_start_date) if facility_letter_start_date.present?
    scope = scope.where('loans.facility_letter_date <= ?', facility_letter_end_date) if facility_letter_end_date.present?
    scope = scope.where('loans.created_at >= ?', created_at_start_date.beginning_of_day) if created_at_start_date.present?
    scope = scope.where('loans.created_at <= ?', created_at_end_date.end_of_day) if created_at_end_date.present?
    scope = scope.where('loans.last_modified_at >= ?', last_modified_start_date.beginning_of_day) if last_modified_start_date.present?
    scope = scope.where('loans.last_modified_at <= ?', last_modified_end_date.end_of_day) if last_modified_end_date.present?

    if loan_sources && loan_sources.include?(Loan::LEGACY_SFLG_SOURCE)
      scope = scope.where("loans.modified_by_legacy_id IS NULL OR loans.modified_by_legacy_id != 'migration'")
    end

    scope.joins(
      'LEFT JOIN ded_codes ON loans.dti_ded_code = ded_codes.code',
      'LEFT JOIN invoices ON loans.invoice_id = invoices.id',
      'LEFT JOIN lending_limits ON loans.lending_limit_id = lending_limits.id',
      'LEFT JOIN loan_modifications AS initial_draw_change ON initial_draw_change.loan_id = loans.id AND initial_draw_change.type = "InitialDrawChange"',
      'LEFT JOIN users AS created_by_user ON loans.created_by_id = created_by_user.id',
      'LEFT JOIN users AS modified_by_user ON loans.modified_by_id = modified_by_user.id',
    )
  end

  def count
    @count ||= loans.count
  end
end

class LoanReport < BaseLoanReport

  class LenderNotAllowed < ArgumentError; end

  ALLOWED_LOAN_SOURCES = [ Loan::SFLG_SOURCE, Loan::LEGACY_SFLG_SOURCE ].freeze

  ALLOWED_LOAN_SCHEMES = [ Loan::EFG_SCHEME, Loan::SFLG_SCHEME ].freeze

  attr_accessor :allowed_lender_ids, :states, :loan_sources, :loan_scheme, :lender_ids, :created_by_id

  date_attribute :facility_letter_start_date, :facility_letter_end_date,
                 :created_at_start_date, :created_at_end_date,
                 :last_modified_start_date, :last_modified_end_date

  validates_presence_of :allowed_lender_ids, :lender_ids, :loan_sources

  validates_numericality_of :created_by_id, allow_blank: true

  validates_inclusion_of :loan_scheme, in: ALLOWED_LOAN_SCHEMES, allow_blank: true

  validate :lender_ids_are_allowed

  validate :loan_sources_are_allowed

  validate :loan_states_are_allowed

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

    if loan_sources.include?(Loan::LEGACY_SFLG_SOURCE)
      scope = scope.where("loans.modified_by_legacy_id != 'migration'")
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

  def loan_sources=(sources)
    @loan_sources = filter_blank_multi_select(sources)
  end

  def states=(states)
    @states = filter_blank_multi_select(states)
  end

  def lender_ids=(lender_ids)
    @lender_ids = filter_blank_multi_select(lender_ids)
  end

  private

  def lender_ids_are_allowed
    return if lender_ids.blank?

    disallowed_lender_ids = lender_ids.collect(&:to_i) - allowed_lender_ids.collect(&:to_i)
    unless disallowed_lender_ids.empty?
      raise LoanReport::LenderNotAllowed, "Access to loans for lender(s) with ID #{disallowed_lender_ids.join(',')} is forbidden for this report"
    end
  end

  def loan_sources_are_allowed
    if loan_sources.present? && loan_sources.any? { |source| !ALLOWED_LOAN_SOURCES.include?(source) }
      errors.add(:loan_sources, :inclusion)
    end
  end

  def loan_states_are_allowed
    if states.present? && states.any? { |state| !ALLOWED_LOAN_STATES.include?(state) }
      errors.add(:states, :inclusion)
    end
  end

  # See http://stackoverflow.com/questions/8929230/why-is-the-first-element-always-blank-in-my-rails-multi-select
  def filter_blank_multi_select(values)
    values.is_a?(Array) ? values.reject(&:blank?) : values
  end

end

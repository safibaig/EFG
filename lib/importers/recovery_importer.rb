class RecoveryImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_LOAN_RECOVERED_DATA_TABLE.csv')
  self.klass = Recovery

  def self.extra_columns
    [:created_by_id, :loan_id]
  end

  def self.field_mapping
    {
      'OID'                             => :legacy_loan_id,
      'SEQ'                             => :seq,
      'RECOVERED_DATE'                  => :recovered_on,
      'TOTAL_PROCEEDS_RECOVERED'        => :total_proceeds_recovered,
      'TOTAL_LIABILITIES_AFTER_DEMAND'  => :total_liabilities_after_demand,
      'TOTAL_LIABILITIES_BEHIND'        => :total_liabilities_behind,
      'ADDITIONAL_BREAK_COSTS'          => :additional_break_costs,
      'ADDITIONAL_INTEREST_ACCRUED'     => :additional_interest_accrued,
      'AMOUNT_DUE_TO_DTI'               => :amount_due_to_dti,
      'REALISE_FLAG'                    => :realise_flag,
      'MODIFIED_DATE'                   => :created_at,
      'MODIFIED_USER'                   => :legacy_created_by,
      'AR_TIMESTAMP'                    => :ar_timestamp,
      'AR_INSERT_TIMESTAMP'             => :ar_insert_timestamp,
      'OUTSTANDING_NON_EFG_DEBT'        => :outstanding_non_efg_debt,
      'NON_LINKED_SECURITY_PROCEEDS'    => :non_linked_security_proceeds,
      'LINKED_SECURITY_PROCEEDS'        => :linked_security_proceeds,
      'REALISATIONS_ATTRIBUTABLE'       => :realisations_attributable,
      'REALISATIONS_DUE_TO_GOV'         => :realisations_due_to_gov
    }
  end

  DATES = %w(RECOVERED_DATE MODIFIED_DATE)
  MONIES = %w(TOTAL_PROCEEDS_RECOVERED TOTAL_LIABILITIES_AFTER_DEMAND
    TOTAL_LIABILITIES_BEHIND ADDITIONAL_BREAK_COSTS
    ADDITIONAL_INTEREST_ACCRUED AMOUNT_DUE_TO_DTI OUTSTANDING_NON_EFG_DEBT
    NON_LINKED_SECURITY_PROCEEDS LINKED_SECURITY_PROCEEDS
    REALISATIONS_ATTRIBUTABLE REALISATIONS_DUE_TO_GOV)

  def build_attributes
    row.each do |key, value|
      case key
      when 'MODIFIED_USER'
        attributes[:created_by_id] = self.class.user_id_from_username(value)
      when 'OID'
        attributes[:loan_id] = self.class.loan_id_from_legacy_id(value)
      when *DATES
        value = Date.parse(value)
      when *MONIES
        value = Money.parse(value).cents if value.present?
      end
  
      attributes[self.class.field_mapping[key]] = value
    end
  end
end

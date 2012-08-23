class RealisationStatementImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_RECOVERY_STATEMENT_DATA_TABLE.csv')
  self.klass = RealisationStatement

  def self.extra_columns
    [:created_by_id, :lender_id, :period_covered_quarter, :period_covered_year]
  end

  def self.field_mapping
    {
      'OID'                     => :legacy_id,
      'VERSION'                 => :version,
      'LENDER_OID'              => :legacy_lender_id,
      'RECOVERY_REFERENCE'      => :reference,
      'PERIOD_COVERED_TO_DATE'  => :period_covered_to_date,
      'RECOVERY_RECEIVED_DATE'  => :received_on,
      'CREATED_BY'              => :legacy_created_by,
      'CREATION_TIME'           => :created_at,
      'AR_TIMESTAMP'            => :ar_timestamp,
      'AR_INSERT_TIMESTAMP'     => :ar_insert_timestamp
    }
  end

  DATES = %w(PERIOD_COVERED_TO_DATE RECOVERY_RECEIVED_DATE)

  def build_attributes
    row.each do |key, value|
      case key
      when 'CREATED_BY'
        attributes[:created_by_id] = self.class.user_id_from_username(value)
      when 'LENDER_OID'
        attributes[:lender_id] = self.class.lender_id_from_legacy_id(value)
      when *DATES
        value = Date.parse(value)
      end

      if key == 'PERIOD_COVERED_TO_DATE'
        attributes[:period_covered_quarter] = value.strftime('%B')
        attributes[:period_covered_year] = value.year
      end

      attributes[self.class.field_mapping[key]] = value
    end
  end
end

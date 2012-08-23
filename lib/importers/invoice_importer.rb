class InvoiceImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_INVOICE_DATA_TABLE.csv')
  self.klass = Invoice

  def self.extra_columns
    [:created_by_id, :lender_id, :period_covered_quarter, :period_covered_year]
  end

  def self.field_mapping
    {
      'OID' => :legacy_id,
      'VERSION' => :version,
      'LENDER_OID' => :legacy_lender_oid,
      'INVOICE_REFERENCE' => :reference,
      'INVOICE_XREF' => :xref,
      'PERIOD_COVERED_TO_DATE' => :period_covered_to_date,
      'INVOICE_RECEIVED_DATE' => :received_on,
      'CREATED_BY' => :created_by_legacy_id,
      'CREATION_TIME' => :creation_time,
      'AR_TIMESTAMP' => :ar_timestamp,
      'AR_INSERT_TIMESTAMP' => :ar_insert_timestamp
    }
  end

  def build_attributes
    row.each do |name, value|
      case name
      when 'CREATED_BY'
        attributes[:created_by_id] = self.class.user_id_from_username(value)
      when 'INVOICE_RECEIVED_DATE'
        value = Date.parse(value)
      when 'LENDER_OID'
        attributes[:lender_id] = self.class.lender_id_from_legacy_id(value.to_i)
      when 'PERIOD_COVERED_TO_DATE'
        date = Date.parse(value)

        attributes[:period_covered_quarter] = date.strftime('%B')
        attributes[:period_covered_year] = date.year
      end

      attributes[self.class.field_mapping[name]] = value
    end
  end
end

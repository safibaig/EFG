class LoanIneligibilityReasonImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_LOAN_RR_DATA_TABLE.csv')
  self.klass = LoanIneligibilityReason

  def self.field_mapping
    {
      "OID"                 => :loan_id,
      "SEQUENCE"            => :sequence,
      "REASON"              => :reason,
      "AR_TIMESTAMP"        => :ar_timestamp,
      "AR_INSERT_TIMESTAMP" => :ar_insert_timestamp
    }
  end

  TIMES = %w(AR_TIMESTAMP AR_INSERT_TIMESTAMP)

  def build_attributes
    row.each do |field_name, value|
      value = case field_name
      when 'OID'
        self.class.loan_id_from_legacy_id(value.to_i)
      when 'REASON'
        value.gsub("<br/>", "\n")
      else
        value
      end

      attributes[self.class.field_mapping[field_name]] = value
    end
  end
end

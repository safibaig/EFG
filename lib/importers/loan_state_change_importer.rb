class LoanStateChangeImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_LOAN_AUDIT_DATA_TABLE.csv')
  self.klass = LoanStateChange

  def self.extra_columns
    [:loan_id, :modified_by_id]
  end

  def self.field_mapping
    {
      "OID"                 => :legacy_id,
      "VERSION"             => :version,
      "STATUS"              => :state,
      "LAST_MODIFIED"       => :modified_on,
      "MODIFIED_BY"         => :modified_by_legacy_id,
      "EVENT_ID"            => :event_id,
      "AR_TIMESTAMP"        => :ar_timestamp,
      "AR_INSERT_TIMESTAMP" => :ar_insert_timestamp
    }
  end

  DATES = %w(LAST_MODIFIED)
  TIMES = %w(AR_TIMESTAMP AR_INSERT_TIMESTAMP)

  def build_attributes
    row.each do |name, value|
      case name
      when "OID"
        attributes[:loan_id] = self.class.loan_id_from_legacy_id(value)
        value
      when "STATUS"
        value = LOAN_STATE_MAPPING[value]
      when "MODIFIED_BY"
        attributes[:modified_by_id] = self.class.user_id_from_username(value)
        value
      when *DATES
        value = Date.parse(value) unless value.blank?
      when *TIMES
        value = Time.parse(value) unless value.blank?
      end

      attributes[self.class.field_mapping[name]] = value
    end
  end
end

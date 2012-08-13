class LoanAllocationImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_LENDER_CAP_ALLOC_DATA_TABLE.csv')
  self.klass = LoanAllocation

  def self.field_mapping
    {
      "__LENDER_ID__"       => :lender_id,
      "OID"                 => :legacy_id,
      "LENDER_ID"           => :lender_legacy_id,
      "VERSION"             => :version,
      "TYPE"                => :allocation_type,
      "ACTIVE"              => :active,
      "ALLOCATION"          => :allocation,
      "START_DATE"          => :starts_on,
      "END_DATE"            => :ends_on,
      "DESCRIPTION"         => :description,
      "MODIFIED_BY"         => :modified_by_legacy_id,
      "MODIFIED_DATE"       => :updated_at,
      "AR_TIMESTAMP"        => :ar_timestamp,
      "AR_INSERT_TIMESTAMP" => :ar_insert_timestamp,
      "PREMIUM_RATE"        => :premium_rate,
      "GUARANTEE_RATE"      => :guarantee_rate
    }
  end

  DATES = %w(START_DATE END_DATE)
  TIMES = %w(AR_TIMESTAMP AR_INSERT_TIMESTAMP MODIFIED_DATE)
  MONIES = %(ALLOCATION)

  def build_attributes
    row.each do |field_name, value|
      value = case field_name
      when 'LENDER_ID'
        attributes[:lender_id] = Lender.find_by_legacy_id(value).id unless value.blank?
        value
      when *MONIES
        Money.parse(value).cents
      when *DATES
        Date.parse(value) unless value.blank?
      when *TIMES
        Time.parse(value) unless value.blank?
      else
        value
      end

      attributes[self.class.field_mapping[field_name]] = value
    end
  end
end

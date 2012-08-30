class LendingLimitImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_LENDER_CAP_ALLOC_DATA_TABLE.csv')
  self.klass = LendingLimit

  def self.extra_columns
    [:lender_id, :modified_by_id]
  end

  def self.field_mapping
    {
      "OID"                 => :legacy_id,
      "LENDER_ID"           => :lender_legacy_id,
      "VERSION"             => :version,
      "TYPE"                => :allocation_type_id,
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
      case field_name
      when 'LENDER_ID'
        attributes[:lender_id] = self.class.lender_id_from_legacy_id(value) unless value.blank?
      when 'MODIFIED_BY'
        attributes[:modified_by_id] = self.class.user_id_from_username(value)
      when *MONIES
        value = Money.parse(value).cents
      when *DATES
        value = Date.parse(value) unless value.blank?
      when *TIMES
        value = Time.parse(value) unless value.blank?
      end

      attributes[self.class.field_mapping[field_name]] = value
    end
  end
end

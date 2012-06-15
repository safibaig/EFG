class LoanAllocationImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/loan_allocations.csv')
  self.klass = LoanAllocation

  def self.field_mapping
    {
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

  MONIES = %(ALLOCATION)

  def attributes
    row.inject({}) do |memo, (field_name, value)|
      value = case field_name
      when 'LENDER_ID'
        memo[:lender_id] = Lender.find_by_legacy_id(value).id unless value.blank?
        value
      when *MONIES
        Money.parse(value).cents
      else
        value
      end

      memo[self.class.field_mapping[field_name]] = value
      memo
    end
  end

  # insert lender_id column
  def self.columns
    columns = field_mapping.values
    index = columns.index(:lender_legacy_id)
    columns.insert(index, :lender_id)
  end
end

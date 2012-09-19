class DemandToBorrowerImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_DEMAND_TO_BORROWER_DATA_TABLE.csv')
  self.klass = DemandToBorrower

  def self.extra_columns
    [:created_by_id, :loan_id]
  end

  def self.field_mapping
    {
      'OID'                             => :legacy_loan_id,
      'SEQ'                             => :seq,
      'DATE_OF_DEMAND'                  => :date_of_demand,
      'BALANCE_DEMANDED'                => :demanded_amount,
      'MODIFIED_DATE'                   => :modified_date,
      'MODIFIED_USER'                   => :legacy_created_by,
      'AR_TIMESTAMP'                    => :ar_timestamp,
      'AR_INSERT_TIMESTAMP'             => :ar_insert_timestamp
    }
  end

  def build_attributes
    row.each do |key, value|
      case key
      when 'BALANCE_DEMANDED'
        value = Money.parse(value).cents
      when 'DATE_OF_DEMAND', 'MODIFIED_DATE'
        value = Date.parse(value)
      when 'MODIFIED_USER'
        attributes[:created_by_id] = self.class.user_id_from_username(value)
      when 'OID'
        attributes[:loan_id] = self.class.loan_id_from_legacy_id(value)
      end

      attributes[self.class.field_mapping[key]] = value
    end
  end
end

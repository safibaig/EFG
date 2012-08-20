class LoanRealisationImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_LOAN_REALISE_MONEY_DATA_TABLE.csv')
  self.klass = LoanRealisation

  def self.extra_columns
    [:created_by_id, :realised_loan_id]
  end

  def self.field_mapping
    {
      'OID'                 => :legacy_loan_id,
      'REALISED_DATE'       => :realised_on,
      'REALISED_AMOUNT'     => :realised_amount,
      'MODIFIED_DATE'       => :created_at,
      'MODIFIED_USER'       => :legacy_created_by,
      'AR_TIMESTAMP'        => :ar_timestamp,
      'AR_INSERT_TIMESTAMP' => :ar_insert_timestamp,
      'SEQ'                 => :seq
    }
  end

  def build_attributes
    row.each do |key, value|
      case key
      when 'MODIFIED_USER'
        attributes[:created_by_id] = self.class.user_id_from_username(value)
      when 'OID'
        attributes[:realised_loan_id] = self.class.loan_id_from_legacy_id(value)
      when 'MODIFIED_DATE', 'REALISED_DATE'
        value = Date.parse(value)
      when 'REALISED_AMOUNT'
        value = Money.parse(value).cents
      end

      attributes[self.class.field_mapping[key]] = value
    end
  end
end

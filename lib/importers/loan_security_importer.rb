class LoanSecurityImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_LOAN_SECURITY_DATA_TABLE.csv')
  self.klass = LoanSecurity

  def self.field_mapping
    {
      "LOAN_OID"  => :loan_id,
      "TYPE_CODE" => :loan_security_type_id
    }
  end

  def build_attributes
    row.each do |field_name, value|
      value = case field_name
      when 'LOAN_OID'
        self.class.loan_id_from_legacy_id(value.to_i)
      else
        value
      end

      attributes[self.class.field_mapping[field_name]] = value
    end
  end
end

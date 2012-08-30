class DedCodeImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_DED_DATA_TABLE.csv')
  self.klass = DedCode

  def self.field_mapping
    {
      'OID'                  => :legacy_id,
      'GROUP_DESCRIPTION'    => :group_description,
      'CATEGORY_DESCRIPTION' => :category_description,
      'CODE'                 => :code,
      'CODE_DESCRIPTION'     => :code_description,
      'AR_TIMESTAMP'         => :ar_timestamp,
      'AR_INSERT_TIMESTAMP'  => :ar_insert_timestamp
    }
  end

end

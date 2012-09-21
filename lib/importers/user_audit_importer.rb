require 'importers'

class UserAuditImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_USER_AUDIT_DATA_TABLE.csv')
  self.klass = UserAudit

  def self.extra_columns
    [:user_id, :modified_by_id]
  end

  def self.field_mapping
    {
      'USER_ID'             => :legacy_id,
      'VERSION'             => :version,
      'LAST_MODIFIED'       => :updated_at,
      'MODIFIED_BY'         => :modified_by_legacy_id,
      'PASSWORD'            => :password,
      'FUNCTION'            => :function,
      'AR_TIMESTAMP'        => :ar_timestamp,
      'AR_INSERT_TIMESTAMP' => :ar_insert_timestamp
    }
  end

  def build_attributes
    row.each do |field_name, value|
      case field_name
      when 'USER_ID'
        attributes[:user_id] = self.class.user_id_from_username(value)
      when 'MODIFIED_BY'
        attributes[:modified_by_id] = self.class.user_id_from_username(value)
      end

      attributes[self.class.field_mapping[field_name]] = value
    end
  end

end

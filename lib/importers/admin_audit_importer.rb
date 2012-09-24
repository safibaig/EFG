class AdminAuditImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_ADMIN_AUDIT_DATA_TABLE.csv')
  self.klass = AdminAudit

  def self.extra_columns
    [:auditable_id, :auditable_type, :modified_by_id]
  end

  def self.field_mapping
    {
      'OID' => :legacy_id,
      'OBJECT_ID' => :legacy_object_id,
      'OBJECT_TYPE' => :legacy_object_type,
      'OBJECT_VERSION' => :legacy_object_version,
      'MODIFIED_ON' => :modified_on,
      'MODIFIED_BY' => :legacy_modified_by,
      'ACTION' => :action,
      'AR_TIMESTAMP' => :ar_timestamp,
      'AR_INSERT_TIMESTAMP' => :ar_insert_timestamp
    }
  end

  def build_attributes
    row.each do |name, value|
      case name
      when 'MODIFIED_BY'
        attributes[:modified_by_id] = self.class.user_id_from_username(value)
      when 'MODIFIED_ON'
        value = Date.parse(value)
      end

      attributes[self.class.field_mapping[name]] = value
    end

    AdminAuditImporter.instance_variable_set(:@lender_id_from_legacy_id, nil)
    AdminAuditImporter.instance_variable_set(:@lending_limit_id_from_legacy_id, nil)
    AdminAuditImporter.instance_variable_set(:@user_id_from_username, nil)

    case attributes[:legacy_object_type]
    when 'lender'
      attributes[:auditable_type] = 'Lender'
      attributes[:auditable_id] = self.class.lender_id_from_legacy_id(attributes[:legacy_object_id])
    when 'lender_cap_alloc'
      attributes[:auditable_type] = 'LendingLimit'
      attributes[:auditable_id] = self.class.lending_limit_id_from_legacy_id(attributes[:legacy_object_id])
    when 'user'
      attributes[:auditable_type] = 'User'
      attributes[:auditable_id] = self.class.user_id_from_username(attributes[:legacy_object_id])
    else
      raise ArgumentError, "Unknown object type #{attributes[:legacy_object_type].inspect}"
    end
  end
end

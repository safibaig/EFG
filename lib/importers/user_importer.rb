class UserImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/users.csv')
  self.klass = User

  FIELD_MAPPING = {
    "USER_ID"              => :legacy_id,
    "LENDER_OID"           => :lender_id,
    "PASSWORD"             => :password,
    "CREATION_TIME"        => :created_at,
    "LAST_MOD_TIME"        => :updated_at,
    "LAST_LOGIN_TIME"      => :last_sign_in_at,
    "VERSION"              => :version,
    "FIRST_NAME"           => :first_name,
    "LAST_NAME"            => :last_name,
    "DISABLED"             => :disabled,
    "MEMORABLE_NAME"       => :memorable_name,
    "MEMORABLE_PLACE"      => :memorable_place,
    "MEMORABLE_YEAR"       => :memorable_year,
    "LOGIN_FAILURES"       => :login_failures,
    "PASSWORD_CHANGE_TIME" => :password_changed_at,
    "LOCKED"               => :locked,
    "AR_TIMESTAMP"         => :ar_timestamp,
    "AR_INSERT_TIMESTAMP"  => :ar_insert_timestamp,
    "EMAIL_ADDRESS"        => :email,
    "CREATOR_USER_ID"      => :created_by,
    "CONFIRM_T_AND_C"      => :confirm_t_and_c,
    "MODIFIED_BY"          => :modified_by,
    "KNOWLEDGE_RESOURCE"   => :knowledge_resource
  }

  def attributes
    attrs = {}
    @row.each do |field_name, value|

      # handle special fields so User validates
      case field_name
      when "EMAIL_ADDRESS"
        value = "user#{@row_number}@example.com"
      when "PASSWORD"
        attrs[:password_confirmation] = value
      when "LENDER_OID"
        value = 0 if value.blank?
      end

      attrs[FIELD_MAPPING[field_name]] = value
    end
    attrs
  end
end

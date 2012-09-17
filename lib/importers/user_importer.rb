class UserImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_USER_DATA_TABLE.csv')
  self.klass = User

  def self.field_mapping
    {
      'USER_ID'              => :username,
      'LENDER_OID'           => :legacy_lender_id,
      'PASSWORD'             => :encrypted_password,
      'CREATION_TIME'        => :created_at,
      'LAST_MOD_TIME'        => :updated_at,
      'LAST_LOGIN_TIME'      => :last_sign_in_at,
      'VERSION'              => :version,
      'FIRST_NAME'           => :first_name,
      'LAST_NAME'            => :last_name,
      'DISABLED'             => :disabled,
      'MEMORABLE_NAME'       => :memorable_name,
      'MEMORABLE_PLACE'      => :memorable_place,
      'MEMORABLE_YEAR'       => :memorable_year,
      'LOGIN_FAILURES'       => :login_failures,
      'PASSWORD_CHANGE_TIME' => :password_changed_at,
      'LOCKED'               => :locked,
      'AR_TIMESTAMP'         => :ar_timestamp,
      'AR_INSERT_TIMESTAMP'  => :ar_insert_timestamp,
      'EMAIL_ADDRESS'        => :legacy_email,
      'CREATOR_USER_ID'      => :created_by_legacy_id,
      'CONFIRM_T_AND_C'      => :confirm_t_and_c,
      'MODIFIED_BY'          => :modified_by_legacy_id,
      'KNOWLEDGE_RESOURCE'   => :knowledge_resource
    }
  end

  def build_attributes
    row.each do |field_name, value|
      case field_name
      when 'PASSWORD'
        value = nil
      else
        value
      end

      attributes[self.class.field_mapping[field_name]] = value
    end
  end

  private

  def self.after_import
    klass.find_each do |user|
      user.created_by_id = user_id_from_username(user.created_by_legacy_id)
      user.modified_by_id = user_id_from_username(user.modified_by_legacy_id)

      user.type = UserRoleMapper.new(user).user_type

      if %w(LenderUser LenderAdmin).include?(user.type)
        user.lender_id = lender_id_from_legacy_id(user.legacy_lender_id)
      else
        # Non-LenderAdmin/LenderUsers cannot login until they have been
        # manually verified
        user.disabled = true
      end

      user.save!(validate: false)
    end
  end
end

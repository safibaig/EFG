class LoanChangeImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_LOAN_CHANGES_DATA_TABLE.csv')
  self.klass = LoanChange

  def self.extra_columns
    [:created_by_id, :loan_id]
  end

  def self.field_mapping
    {
      'OID' => :oid,
      'SEQ' => :seq,
      'DATE_OF_CHANGE' => :date_of_change,
      'MATURITY_DATE' => :maturity_date,
      'OLD_MATURITY_DATE' => :old_maturity_date,
      'BUSINESS_NAME' => :business_name,
      'OLD_BUSINESS_NAME' => :old_business_name,
      'LUMP_SUM_REPAYMENT' => :lump_sum_repayment,
      'AMOUNT_DRAWN' => :amount_drawn,
      'MODIFIED_DATE' => :modified_date,
      'MODIFIED_USER' => :modified_user,
      'CHANGE_TYPE' => :change_type_id,
      'AR_TIMESTAMP' => :ar_timestamp,
      'AR_INSERT_TIMESTAMP' => :ar_insert_timestamp,
      'AMOUNT' => :amount,
      'OLD_AMOUNT' => :old_amount,
      'GUARANTEED_DATE' => :guaranteed_date,
      'OLD_GUARANTEED_DATE' => :old_guaranteed_date,
      'INITIAL_DRAW_DATE' => :initial_draw_date,
      'OLD_INITIAL_DRAW_DATE' => :old_initial_draw_date,
      'INITIAL_DRAW_AMOUNT' => :initial_draw_amount,
      'OLD_INITIAL_DRAW_AMOUNT' => :old_initial_draw_amount,
      'SORTCODE' => :sortcode,
      'OLD_SORTCODE' => :old_sortcode,
      'DTIDEMANDOUTAMOUNT' => :dti_demand_out_amount,
      'OLD_DTIDEMANDOUTAMOUNT' => :old_dti_demand_out_amount,
      'DTIDEMANDINTEREST' => :dti_demand_interest,
      'OLD_DTIDEMANDINTEREST' => :old_dti_demand_interest,
      'CAP_ID' => :cap_id,
      'OLD_CAP_ID' => :old_cap_id,
      'LOAN_TERM' => :loan_term,
      'OLD_LOAN_TERM' => :old_loan_term
    }
  end

  def self.user_id_from_modified_user(modified_user)
    @user_id_from_modified_user ||= Hash[*User.select('id, username').map { |user|
      [user.username, user.id]
    }.flatten]

    @user_id_from_modified_user[modified_user]
  end

  DATES = %w(DATE_OF_CHANGE MATURITY_DATE OLD_MATURITY_DATE MODIFIED_DATE
    AR_TIMESTAMP AR_INSERT_TIMESTAMP GUARANTEED_DATE OLD_GUARANTEED_DATE
    INITIAL_DRAW_DATE OLD_INITIAL_DRAW_DATE)
  MONIES = %w(LUMP_SUM_REPAYMENT AMOUNT_DRAWN AMOUNT OLD_AMOUNT
    INITIAL_DRAW_AMOUNT OLD_INITIAL_DRAW_AMOUNT DTIDEMANDOUTAMOUNT
    OLD_DTIDEMANDOUTAMOUNT DTIDEMANDINTEREST OLD_DTIDEMANDINTEREST)

  def build_attributes
    row.each do |name, value|
      value = nil if value.blank?

      case name
      when 'MODIFIED_USER'
        attributes[:created_by_id] = self.class.user_id_from_modified_user(value)
      when 'OID'
        attributes[:loan_id] = self.class.loan_id_from_legacy_id(value.to_i)
      when 'SEQ'
        value = value.to_i
      when *DATES
        value = Date.parse(value) if value
      when *MONIES
        value = Money.parse(value).cents if value
      end

      attributes[self.class.field_mapping[name]] = value
    end
  end
end

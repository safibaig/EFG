require 'data-anonymization'

DataAnon::Utils::Logging.logger.level = Logger::INFO

# ENV['show_progress'] = 'false'

class Extractor
  # ActiveRecord::Batches#find_in_batches defaults to find records with an id > 0.
  # Our SystemUser has an id of -1, therfore we need a query starting from -1.
  #
  # This module gets included on the users source_table, which is an anonymous
  # subclass of ActiveRecord::Base.
  module UserFindInBatchesModification
    def find_in_batches(options = {})
      super(options.merge(start: -1))
    end
  end

  class << self
    def run
      Bundler.require(:extract)
      database_config = YAML.load_file("config/database.yml")
      import_schema(database_config)
      extract(database_config)
    end

    private

    def import_schema(database_config)
      extract_config = database_config["extract"]

      case extract_config["adapter"]
      when /sqlite/
        sqlite_file = extract_config["database"]

        if !File.directory?(File.dirname(sqlite_file))
          Dir.mkdir(File.dirname(sqlite_file))
        end
      end

      existing_connection_config = ActiveRecord::Base.connection_config
      drop_database_and_rescue(extract_config)
      ActiveRecord::Base.establish_connection(extract_config)
      load("db/schema.rb")
      ActiveRecord::Base.remove_connection
      ActiveRecord::Base.establish_connection(existing_connection_config)
    end

    def drop_database(config)
      case config['adapter']
      when /mysql/
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection.drop_database config['database']
      when /sqlite/
        require 'pathname'
        path = Pathname.new(config['database'])
        file = path.absolute? ? path.to_s : File.join(Rails.root, path)

        FileUtils.rm(file)
      when /postgresql/
        ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
        ActiveRecord::Base.connection.drop_database config['database']
      end
    end

    def drop_database_and_rescue(config)
      begin
        drop_database(config)
      rescue Exception => e
        $stderr.puts "Couldn't drop #{config['database']} : #{e.inspect}"
      end
    end

    def extract(database_config)
      database 'efg' do
        # Whitelist so that new fields are obfuscated by default.
        strategy DataAnon::Strategy::Whitelist

        # Tried this, but we get errors. Presumably due to foreign key issues?
        # execution_strategy DataAnon::Parallel::Table

        default_field_strategies ({
          :"activesupport::timewithzone" => FieldStrategy::DateTimeDelta.new,
          :string => ColumnNameStrategy.new,
        })

        # Get the connection config from Rails
        source_db ActiveRecord::Base.connection_config

        # Dump to a local sqlite file.
        destination_db database_config["extract"]

        table 'admin_audits' do
          batch_size 200
          primary_key 'id'

          whitelist 'auditable_type'
          whitelist 'auditable_id'
          whitelist 'modified_by_id'
          whitelist 'modified_on'
          whitelist 'action'
          whitelist 'legacy_id'
          whitelist 'legacy_object_id'
          whitelist 'legacy_object_type'
          whitelist 'legacy_object_version'
          whitelist 'legacy_modified_by'
          whitelist 'ar_timestamp'
          whitelist 'ar_insert_timestamp'
          whitelist 'created_at'
          whitelist 'updated_at'
        end

        table 'ded_codes' do
          primary_key "id"

          whitelist "legacy_id"
          whitelist "group_description"
          whitelist "category_description"
          whitelist "code"
          whitelist "code_description"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "created_at"
          whitelist "updated_at"
        end

        table 'lenders' do
          primary_key 'id'

          anonymize("main_point_of_contact_user")
          anonymize("name") { |field| "lender-#{field.row_number}" }
          anonymize("primary_contact_email") { |field| "lender-#{field.row_number}@example.com" }
          anonymize("primary_contact_name") { |field| "primary contact #{field.row_number}" }
          anonymize("primary_contact_phone") { |field| "primary phone #{field.row_number}" }

          whitelist "created_at"
          whitelist "updated_at"
          whitelist "legacy_id"
          whitelist "version"
          whitelist "high_volume"
          whitelist "can_use_add_cap"
          whitelist "organisation_reference_code"
          whitelist "std_cap_lending_allocation"
          whitelist "add_cap_lending_allocation"
          whitelist "disabled"
          whitelist "created_by_legacy_id"
          whitelist "modified_by_legacy_id"
          whitelist "allow_alert_process"
          whitelist "loan_scheme"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "created_by_id"
          whitelist "modified_by_id"
        end

        table 'users' do
          batch_size 200
          primary_key 'id'

          # Ensure the SystemUser is correctly extracted.
          #
          # Note: Must extend this after we set the primary_key.
          source_table.extend(UserFindInBatchesModification)

          anonymize("email") { |field| "user-#{field.row_number}@example.com" }
          anonymize("first_name")
          anonymize("last_name")
          anonymize("legacy_email") { |field| "legacy-#{field.row_number}@example.com" }
          anonymize("memorable_name")
          anonymize("memorable_place")
          anonymize("memorable_year")
          anonymize('username') { |field| "username_#{field.row_number}" }

          whitelist 'reset_password_token'
          whitelist 'type'
          whitelist "encrypted_password"
          whitelist "reset_password_token"
          whitelist "reset_password_sent_at"
          whitelist "sign_in_count"
          whitelist "current_sign_in_at"
          whitelist "last_sign_in_at"
          whitelist "current_sign_in_ip"
          whitelist "last_sign_in_ip"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "lender_id"
          whitelist "legacy_lender_id"
          whitelist "version"
          whitelist "disabled"
          whitelist "login_failures"
          whitelist "password_changed_at"
          whitelist "locked"
          whitelist "created_by_legacy_id"
          whitelist "created_by_id"
          whitelist "confirm_t_and_c"
          whitelist "modified_by_legacy_id"
          whitelist "modified_by_id"
          whitelist "knowledge_resource"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "type"
          whitelist "failed_attempts"
          whitelist "password_salt"
        end

        table 'demand_to_borrowers' do
          batch_size 200
          primary_key 'id'

          whitelist 'loan_id'
          whitelist "seq"
          whitelist "created_by_id"
          whitelist "date_of_demand"
          whitelist "demanded_amount"
          whitelist "modified_date"
          whitelist "legacy_loan_id"
          whitelist "legacy_created_by"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "created_at"
          whitelist "updated_at"
        end

        table 'experts' do
          primary_key 'id'

          whitelist 'user_id'
          whitelist 'lender_id'
          whitelist "created_at"
          whitelist "updated_at"
        end

        table 'invoices' do
          batch_size 100
          primary_key 'id'

          whitelist "lender_id"
          whitelist "reference"
          whitelist "period_covered_quarter"
          whitelist "period_covered_year"
          whitelist "received_on"
          whitelist "created_by_id"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "legacy_id"
          whitelist "version"
          whitelist "legacy_lender_oid"
          whitelist "xref"
          whitelist "period_covered_to_date"
          whitelist "created_by_legacy_id"
          whitelist "creation_time"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
        end

        table 'lending_limits' do
          primary_key 'id'

          whitelist 'lender_id'
          whitelist "legacy_id"
          whitelist "lender_legacy_id"
          whitelist "version"
          whitelist "allocation_type_id"
          whitelist "active"
          whitelist "allocation"
          whitelist "starts_on"
          whitelist "ends_on"
          whitelist "name"
          whitelist "modified_by_legacy_id"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "premium_rate"
          whitelist "guarantee_rate"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "modified_by_id"
        end

        table 'loan_ineligibility_reasons' do
          batch_size 200
          primary_key 'id'

          whitelist 'loan_id'
          whitelist "reason"
          whitelist "sequence"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "created_at"
          whitelist "updated_at"
        end

        table 'loan_modifications' do
          batch_size 200
          primary_key 'id'

          anonymize("business_name")
          anonymize("old_business_name")
          anonymize("sortcode")
          anonymize("old_sortcode")

          whitelist "loan_id"
          whitelist "created_by_id"
          whitelist "oid"
          whitelist "seq"
          whitelist "date_of_change"
          whitelist "maturity_date"
          whitelist "old_maturity_date"
          whitelist "lump_sum_repayment"
          whitelist "amount_drawn"
          whitelist "modified_date"
          whitelist "modified_user"
          whitelist "change_type_id"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "amount"
          whitelist "old_amount"
          whitelist "facility_letter_date"
          whitelist "old_facility_letter_date"
          whitelist "initial_draw_date"
          whitelist "old_initial_draw_date"
          whitelist "initial_draw_amount"
          whitelist "old_initial_draw_amount"
          whitelist "dti_demand_out_amount"
          whitelist "old_dti_demand_out_amount"
          whitelist "dti_demand_interest"
          whitelist "old_dti_demand_interest"
          whitelist "lending_limit_id"
          whitelist "old_lending_limit_id"
          whitelist "repayment_duration"
          whitelist "old_repayment_duration"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "type"
        end

        table 'loan_realisations' do
          batch_size 200
          primary_key 'id'

          whitelist 'realisation_statement_id'
          whitelist 'realised_loan_id'
          whitelist "created_by_id"
          whitelist "realised_amount"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "legacy_loan_id"
          whitelist "legacy_created_by"
          whitelist "realised_on"
          whitelist "seq"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
        end

        table 'loan_securities' do
          batch_size 200
          primary_key 'id'

          whitelist "loan_id"
          whitelist "loan_security_type_id"
          whitelist "created_at"
          whitelist "updated_at"
        end

        table 'loan_state_changes' do
          batch_size 200
          primary_key 'id'
          whitelist "loan_id"
          whitelist "legacy_id"
          whitelist "state"
          whitelist "version"
          whitelist "modified_by_id"
          whitelist "modified_by_legacy_id"
          whitelist "event_id"
          whitelist "modified_on"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "modified_at"
        end

        table 'loans' do
          batch_size 200
          primary_key 'id'

          anonymize("business_name")
          anonymize("company_registration")
          anonymize("non_validated_postcode")
          anonymize("postcode")
          anonymize("sortcode")
          anonymize("town")
          anonymize("trading_name")

          whitelist "viable_proposition"
          whitelist "would_you_lend"
          whitelist "collateral_exhausted"
          whitelist "amount"
          whitelist "lender_cap_id"
          whitelist "repayment_duration"
          whitelist "turnover"
          whitelist "trading_date"
          whitelist "sic_code"
          whitelist "loan_category_id"
          whitelist "reason_id"
          whitelist "previous_borrowing"
          whitelist "private_residence_charge_required"
          whitelist "personal_guarantee_required"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "lender_id"
          whitelist "declaration_signed"
          whitelist "generic1"
          whitelist "generic2"
          whitelist "generic3"
          whitelist "generic4"
          whitelist "generic5"
          whitelist "interest_rate_type_id"
          whitelist "interest_rate"
          whitelist "fees"
          whitelist "state_aid_is_valid"
          whitelist "facility_letter_sent"
          whitelist "facility_letter_date"
          whitelist "received_declaration"
          whitelist "signed_direct_debit_received"
          whitelist "first_pp_received"
          whitelist "maturity_date"
          whitelist "state"
          whitelist "legal_form_id"
          whitelist "repayment_frequency_id"
          whitelist "cancelled_on"
          whitelist "cancelled_reason_id"
          whitelist "cancelled_comment"
          whitelist "borrower_demanded_on"
          whitelist "amount_demanded"
          whitelist "repaid_on"
          whitelist "no_claim_on"
          whitelist "dti_demanded_on"
          whitelist "dti_demand_outstanding"
          whitelist "dti_reason"
          whitelist "dti_ded_code"
          whitelist "legacy_id"
          whitelist "reference"
          whitelist "created_by_legacy_id"
          whitelist "version"
          whitelist "guaranteed_on"
          whitelist "modified_by_legacy_id"
          whitelist "lender_legacy_id"
          whitelist "outstanding_amount"
          whitelist "standard_cap"
          whitelist "next_change_history_seq"
          whitelist "borrower_demand_outstanding"
          whitelist "realised_money_date"
          whitelist "event_legacy_id"
          whitelist "state_aid"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "notified_aid"
          whitelist "remove_guarantee_outstanding_amount"
          whitelist "remove_guarantee_on"
          whitelist "remove_guarantee_reason"
          whitelist "dti_amount_claimed"
          whitelist "invoice_legacy_id"
          whitelist "settled_on"
          whitelist "next_borrower_demand_seq"
          whitelist "sic_desc"
          whitelist "sic_parent_desc"
          whitelist "sic_notified_aid"
          whitelist "sic_eligible"
          whitelist "non_val_postcode"
          whitelist "transferred_from_legacy_id"
          whitelist "next_in_calc_seq"
          whitelist "loan_source"
          whitelist "dti_break_costs"
          whitelist "guarantee_rate"
          whitelist "premium_rate"
          whitelist "legacy_small_loan"
          whitelist "next_in_realise_seq"
          whitelist "next_in_recover_seq"
          whitelist "recovery_on"
          whitelist "recovery_statement_legacy_id"
          whitelist "dti_interest"
          whitelist "loan_scheme"
          whitelist "security_proportion"
          whitelist "current_refinanced_amount"
          whitelist "final_refinanced_amount"
          whitelist "original_overdraft_proportion"
          whitelist "refinance_security_proportion"
          whitelist "overdraft_limit"
          whitelist "overdraft_maintained"
          whitelist "invoice_discount_limit"
          whitelist "debtor_book_coverage"
          whitelist "debtor_book_topup"
          whitelist "lending_limit_id"
          whitelist "invoice_id"
          whitelist "transferred_from_id"
          whitelist "created_by_id"
          whitelist "modified_by_id"
          whitelist "legacy_sic_code"
          whitelist "legacy_sic_desc"
          whitelist "legacy_sic_parent_desc"
          whitelist "legacy_sic_notified_aid"
          whitelist "legacy_sic_eligible"
        end

        table 'realisation_statements' do
          primary_key 'id'

          whitelist "lender_id"
          whitelist "created_by_id"
          whitelist "reference"
          whitelist "period_covered_quarter"
          whitelist "period_covered_year"
          whitelist "received_on"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "version"
          whitelist "legacy_id"
          whitelist "legacy_lender_id"
          whitelist "legacy_created_by"
          whitelist "period_covered_to_date"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
        end

        table 'recoveries' do
          batch_size 200
          primary_key 'id'

          whitelist "loan_id"
          whitelist "recovered_on"
          whitelist "total_proceeds_recovered"
          whitelist "total_liabilities_after_demand"
          whitelist "total_liabilities_behind"
          whitelist "additional_break_costs"
          whitelist "additional_interest_accrued"
          whitelist "amount_due_to_dti"
          whitelist "realise_flag"
          whitelist "created_by_id"
          whitelist "outstanding_non_efg_debt"
          whitelist "non_linked_security_proceeds"
          whitelist "linked_security_proceeds"
          whitelist "realisations_attributable"
          whitelist "realisations_due_to_gov"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "realisation_statement_id"
          whitelist "ar_insert_timestamp"
          whitelist "ar_timestamp"
          whitelist "legacy_created_by"
          whitelist "legacy_loan_id"
          whitelist "seq"
        end

        table 'sic_codes' do
          primary_key 'id'

          whitelist 'code'
          whitelist "description"
          whitelist "eligible"
          whitelist "public_sector_restricted"
        end

        table 'premium_schedules' do
          batch_size 200
          primary_key 'id'

          whitelist 'loan_id'
          whitelist 'legacy_loan_id'
          whitelist "initial_draw_year"
          whitelist "initial_draw_amount"
          whitelist "repayment_duration"
          whitelist "initial_capital_repayment_holiday"
          whitelist "second_draw_amount"
          whitelist "second_draw_months"
          whitelist "third_draw_amount"
          whitelist "third_draw_months"
          whitelist "fourth_draw_amount"
          whitelist "fourth_draw_months"
          whitelist "created_at"
          whitelist "updated_at"
          whitelist "seq"
          whitelist "loan_version"
          whitelist "calc_type"
          whitelist "premium_cheque_month"
          whitelist "holiday"
          whitelist "total_cost"
          whitelist "public_funding"
          whitelist "obj1_area"
          whitelist "reduce_costs"
          whitelist "improve_prod"
          whitelist "increase_quality"
          whitelist "improve_nat_env"
          whitelist "promote"
          whitelist "agriculture"
          whitelist "guarantee_rate"
          whitelist "npv"
          whitelist "prem_rate"
          whitelist "euro_conv_rate"
          whitelist "elsewhere_perc"
          whitelist "obj1_perc"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
        end

        table 'user_audits' do
          batch_size 200
          primary_key 'id'

          whitelist 'modified_by_id'
          whitelist 'user_id'
          whitelist "legacy_id"
          whitelist "version"
          whitelist "modified_by_legacy_id"
          whitelist "password"
          whitelist "function"
          whitelist "ar_timestamp"
          whitelist "ar_insert_timestamp"
          whitelist "created_at"
          whitelist "updated_at"
        end
      end
    end
  end

  class ColumnNameStrategy
    def anonymize field
      field.name
    end
  end
end

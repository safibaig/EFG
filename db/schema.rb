# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120927092910) do

  create_table "admin_audits", :force => true do |t|
    t.string   "auditable_type",        :null => false
    t.integer  "auditable_id",          :null => false
    t.integer  "modified_by_id",        :null => false
    t.date     "modified_on",           :null => false
    t.string   "action",                :null => false
    t.integer  "legacy_id"
    t.string   "legacy_object_id"
    t.string   "legacy_object_type"
    t.integer  "legacy_object_version"
    t.string   "legacy_modified_by"
    t.string   "ar_timestamp"
    t.string   "ar_insert_timestamp"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "ded_codes", :force => true do |t|
    t.string   "legacy_id"
    t.string   "group_description"
    t.string   "category_description"
    t.string   "code"
    t.string   "code_description"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "ded_codes", ["code"], :name => "index_ded_codes_on_code", :unique => true

  create_table "demand_to_borrowers", :force => true do |t|
    t.integer  "loan_id",                          :null => false
    t.integer  "seq",                              :null => false
    t.integer  "created_by_id",                    :null => false
    t.date     "date_of_demand",                   :null => false
    t.integer  "demanded_amount",     :limit => 8, :null => false
    t.date     "modified_date",                    :null => false
    t.integer  "legacy_loan_id"
    t.string   "legacy_created_by"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "demand_to_borrowers", ["loan_id", "seq"], :name => "index_demand_to_borrowers_on_loan_id_and_seq", :unique => true

  create_table "experts", :force => true do |t|
    t.integer  "lender_id",  :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "experts", ["lender_id"], :name => "index_experts_on_lender_id"
  add_index "experts", ["user_id"], :name => "index_experts_on_user_id", :unique => true

  create_table "invoices", :force => true do |t|
    t.integer  "lender_id"
    t.string   "reference"
    t.string   "period_covered_quarter"
    t.string   "period_covered_year"
    t.date     "received_on"
    t.integer  "created_by_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "legacy_id"
    t.integer  "version",                :default => 0, :null => false
    t.integer  "legacy_lender_oid"
    t.string   "xref"
    t.string   "period_covered_to_date"
    t.string   "created_by_legacy_id"
    t.string   "creation_time"
    t.string   "ar_timestamp"
    t.string   "ar_insert_timestamp"
  end

  create_table "lenders", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.integer  "legacy_id"
    t.integer  "version"
    t.boolean  "high_volume",                 :default => false, :null => false
    t.boolean  "can_use_add_cap",             :default => false, :null => false
    t.string   "organisation_reference_code"
    t.string   "primary_contact_name"
    t.string   "primary_contact_phone"
    t.string   "primary_contact_email"
    t.integer  "std_cap_lending_allocation"
    t.integer  "add_cap_lending_allocation"
    t.boolean  "disabled",                    :default => false, :null => false
    t.string   "created_by_legacy_id"
    t.string   "modified_by_legacy_id"
    t.boolean  "allow_alert_process",         :default => false, :null => false
    t.string   "main_point_of_contact_user"
    t.string   "loan_scheme"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.integer  "created_by_id",                                  :null => false
    t.integer  "modified_by_id",                                 :null => false
  end

  add_index "lenders", ["legacy_id"], :name => "index_lenders_on_legacy_id", :unique => true
  add_index "lenders", ["organisation_reference_code"], :name => "index_lenders_on_organisation_reference_code", :unique => true

  create_table "lending_limits", :force => true do |t|
    t.integer  "lender_id",                                                                            :null => false
    t.integer  "legacy_id"
    t.integer  "lender_legacy_id"
    t.integer  "version"
    t.integer  "allocation_type_id",                                                                   :null => false
    t.boolean  "active",                                                            :default => false, :null => false
    t.integer  "allocation",            :limit => 8,                                                   :null => false
    t.date     "starts_on",                                                                            :null => false
    t.date     "ends_on",                                                                              :null => false
    t.string   "name",                                                                                 :null => false
    t.string   "modified_by_legacy_id"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.decimal  "premium_rate",                       :precision => 16, :scale => 2,                    :null => false
    t.decimal  "guarantee_rate",                     :precision => 16, :scale => 2,                    :null => false
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
    t.integer  "modified_by_id"
  end

  add_index "lending_limits", ["lender_id"], :name => "index_lending_limits_on_lender_id"

  create_table "loan_ineligibility_reasons", :force => true do |t|
    t.integer  "loan_id"
    t.text     "reason"
    t.integer  "sequence",            :default => 0, :null => false
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "loan_ineligibility_reasons", ["loan_id"], :name => "index_loan_ineligibility_reasons_on_loan_id"

  create_table "loan_modifications", :force => true do |t|
    t.integer  "loan_id",                                               :null => false
    t.integer  "created_by_id",                                         :null => false
    t.string   "oid"
    t.integer  "seq",                                    :default => 0, :null => false
    t.date     "date_of_change",                                        :null => false
    t.date     "maturity_date"
    t.date     "old_maturity_date"
    t.string   "business_name"
    t.string   "old_business_name"
    t.integer  "lump_sum_repayment",        :limit => 8
    t.integer  "amount_drawn",              :limit => 8
    t.date     "modified_date",                                         :null => false
    t.string   "modified_user"
    t.string   "change_type_id"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.integer  "amount",                    :limit => 8
    t.integer  "old_amount",                :limit => 8
    t.date     "facility_letter_date"
    t.date     "old_facility_letter_date"
    t.date     "initial_draw_date"
    t.date     "old_initial_draw_date"
    t.integer  "initial_draw_amount",       :limit => 8
    t.integer  "old_initial_draw_amount",   :limit => 8
    t.string   "sortcode"
    t.string   "old_sortcode"
    t.integer  "dti_demand_out_amount",     :limit => 8
    t.integer  "old_dti_demand_out_amount", :limit => 8
    t.integer  "dti_demand_interest",       :limit => 8
    t.integer  "old_dti_demand_interest",   :limit => 8
    t.integer  "lending_limit_id"
    t.integer  "old_lending_limit_id"
    t.integer  "loan_term"
    t.integer  "old_loan_term"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "type"
  end

  add_index "loan_modifications", ["loan_id", "seq"], :name => "index_loan_changes_on_loan_id_and_seq", :unique => true

  create_table "loan_realisations", :force => true do |t|
    t.integer  "realised_loan_id"
    t.integer  "realisation_statement_id"
    t.integer  "created_by_id"
    t.integer  "realised_amount",          :limit => 8
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "legacy_loan_id"
    t.string   "legacy_created_by"
    t.date     "realised_on"
    t.string   "seq"
    t.string   "ar_timestamp"
    t.string   "ar_insert_timestamp"
  end

  add_index "loan_realisations", ["created_by_id"], :name => "index_loan_realisations_on_created_by_id"
  add_index "loan_realisations", ["realisation_statement_id"], :name => "index_loan_realisations_on_realisation_statement_id"
  add_index "loan_realisations", ["realised_loan_id"], :name => "index_loan_realisations_on_realised_loan_id"

  create_table "loan_securities", :force => true do |t|
    t.integer  "loan_id"
    t.integer  "loan_security_type_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "loan_securities", ["loan_id"], :name => "index_loan_securities_on_loan_id"
  add_index "loan_securities", ["loan_security_type_id"], :name => "index_loan_securities_on_loan_security_type_id"

  create_table "loan_state_changes", :force => true do |t|
    t.integer  "loan_id"
    t.string   "legacy_id"
    t.string   "state"
    t.integer  "version"
    t.integer  "modified_by_id",        :null => false
    t.string   "modified_by_legacy_id"
    t.integer  "event_id",              :null => false
    t.date     "modified_on"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "loan_state_changes", ["loan_id", "modified_on", "id"], :name => "loan_association"

  create_table "loans", :force => true do |t|
    t.boolean  "viable_proposition",                                                                                  :null => false
    t.boolean  "would_you_lend",                                                                                      :null => false
    t.boolean  "collateral_exhausted",                                                                                :null => false
    t.integer  "amount",                              :limit => 8,                                                    :null => false
    t.integer  "lender_cap_id"
    t.integer  "repayment_duration",                                                                                  :null => false
    t.integer  "turnover",                            :limit => 8
    t.date     "trading_date"
    t.string   "sic_code",                                                                                            :null => false
    t.integer  "loan_category_id"
    t.integer  "reason_id"
    t.boolean  "previous_borrowing",                                                                                  :null => false
    t.boolean  "private_residence_charge_required"
    t.boolean  "personal_guarantee_required"
    t.datetime "created_at",                                                                                          :null => false
    t.datetime "updated_at",                                                                                          :null => false
    t.integer  "lender_id",                                                                                           :null => false
    t.boolean  "declaration_signed"
    t.string   "business_name"
    t.string   "trading_name"
    t.string   "company_registration"
    t.string   "postcode"
    t.string   "non_validated_postcode"
    t.string   "sortcode"
    t.string   "generic1"
    t.string   "generic2"
    t.string   "generic3"
    t.string   "generic4"
    t.string   "generic5"
    t.string   "town"
    t.integer  "interest_rate_type_id"
    t.decimal  "interest_rate",                                     :precision => 5,  :scale => 2
    t.integer  "fees",                                :limit => 8
    t.boolean  "state_aid_is_valid"
    t.boolean  "facility_letter_sent"
    t.date     "facility_letter_date"
    t.boolean  "received_declaration"
    t.boolean  "signed_direct_debit_received"
    t.boolean  "first_pp_received"
    t.date     "maturity_date"
    t.string   "state"
    t.integer  "legal_form_id"
    t.integer  "repayment_frequency_id"
    t.date     "cancelled_on"
    t.integer  "cancelled_reason_id"
    t.text     "cancelled_comment"
    t.date     "borrower_demanded_on"
    t.integer  "amount_demanded",                     :limit => 8
    t.date     "repaid_on"
    t.date     "no_claim_on"
    t.date     "dti_demanded_on"
    t.integer  "dti_demand_outstanding",              :limit => 8
    t.text     "dti_reason"
    t.string   "dti_ded_code"
    t.integer  "legacy_id"
    t.string   "reference"
    t.string   "created_by_legacy_id"
    t.integer  "version"
    t.date     "guaranteed_on"
    t.string   "modified_by_legacy_id"
    t.integer  "lender_legacy_id"
    t.integer  "outstanding_amount",                  :limit => 8
    t.boolean  "standard_cap"
    t.integer  "next_change_history_seq"
    t.integer  "borrower_demand_outstanding",         :limit => 8
    t.date     "realised_money_date"
    t.integer  "event_legacy_id"
    t.integer  "state_aid",                           :limit => 8
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.boolean  "notified_aid"
    t.integer  "remove_guarantee_outstanding_amount", :limit => 8
    t.date     "remove_guarantee_on"
    t.string   "remove_guarantee_reason"
    t.integer  "dti_amount_claimed",                  :limit => 8
    t.integer  "invoice_legacy_id"
    t.date     "settled_on"
    t.integer  "next_borrower_demand_seq"
    t.string   "sic_desc"
    t.string   "sic_parent_desc"
    t.boolean  "sic_notified_aid"
    t.boolean  "sic_eligible"
    t.string   "non_val_postcode",                    :limit => 10
    t.integer  "transferred_from_legacy_id"
    t.integer  "next_in_calc_seq"
    t.string   "loan_source",                         :limit => 1
    t.integer  "dti_break_costs",                     :limit => 8
    t.decimal  "guarantee_rate",                                    :precision => 16, :scale => 2
    t.decimal  "premium_rate",                                      :precision => 16, :scale => 2
    t.boolean  "legacy_small_loan"
    t.integer  "next_in_realise_seq"
    t.integer  "next_in_recover_seq"
    t.date     "recovery_on"
    t.integer  "recovery_statement_legacy_id"
    t.integer  "dti_interest",                        :limit => 8
    t.string   "loan_scheme",                         :limit => 1
    t.integer  "business_type"
    t.integer  "payment_period"
    t.decimal  "security_proportion",                               :precision => 5,  :scale => 2
    t.integer  "current_refinanced_amount",           :limit => 8
    t.integer  "final_refinanced_amount",             :limit => 8
    t.decimal  "original_overdraft_proportion",                     :precision => 5,  :scale => 2
    t.decimal  "refinance_security_proportion",                     :precision => 5,  :scale => 2
    t.integer  "overdraft_limit",                     :limit => 8
    t.boolean  "overdraft_maintained"
    t.integer  "invoice_discount_limit",              :limit => 8
    t.decimal  "debtor_book_coverage",                              :precision => 5,  :scale => 2
    t.decimal  "debtor_book_topup",                                 :precision => 5,  :scale => 2
    t.integer  "lending_limit_id"
    t.integer  "invoice_id"
    t.integer  "transferred_from_id"
    t.integer  "created_by_id",                                                                                       :null => false
    t.integer  "modified_by_id",                                                                                      :null => false
    t.string   "legacy_sic_code"
    t.string   "legacy_sic_desc"
    t.string   "legacy_sic_parent_desc"
    t.boolean  "legacy_sic_notified_aid",                                                          :default => false
    t.boolean  "legacy_sic_eligible",                                                              :default => false
  end

  add_index "loans", ["legacy_id"], :name => "index_loans_on_legacy_id", :unique => true
  add_index "loans", ["lender_id"], :name => "index_loans_on_lender_id"
  add_index "loans", ["lending_limit_id"], :name => "index_loans_on_lending_limit_id"
  add_index "loans", ["reference"], :name => "index_loans_on_reference", :unique => true
  add_index "loans", ["state"], :name => "index_loans_on_state"

  create_table "realisation_statements", :force => true do |t|
    t.integer  "lender_id"
    t.integer  "created_by_id"
    t.string   "reference"
    t.string   "period_covered_quarter"
    t.string   "period_covered_year"
    t.date     "received_on"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "version"
    t.string   "legacy_id"
    t.string   "legacy_lender_id"
    t.string   "legacy_created_by"
    t.datetime "period_covered_to_date"
    t.string   "ar_timestamp"
    t.string   "ar_insert_timestamp"
  end

  create_table "recoveries", :force => true do |t|
    t.integer  "loan_id",                                                        :null => false
    t.date     "recovered_on",                                                   :null => false
    t.integer  "total_proceeds_recovered",       :limit => 8
    t.integer  "total_liabilities_after_demand", :limit => 8
    t.integer  "total_liabilities_behind",       :limit => 8
    t.integer  "additional_break_costs",         :limit => 8
    t.integer  "additional_interest_accrued",    :limit => 8
    t.integer  "amount_due_to_dti",              :limit => 8,                    :null => false
    t.boolean  "realise_flag",                                :default => false, :null => false
    t.integer  "created_by_id",                                                  :null => false
    t.integer  "outstanding_non_efg_debt",       :limit => 8,                    :null => false
    t.integer  "non_linked_security_proceeds",   :limit => 8,                    :null => false
    t.integer  "linked_security_proceeds",       :limit => 8,                    :null => false
    t.integer  "realisations_attributable",      :limit => 8,                    :null => false
    t.integer  "realisations_due_to_gov",        :limit => 8
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.integer  "realisation_statement_id"
    t.string   "ar_insert_timestamp"
    t.string   "ar_timestamp"
    t.string   "legacy_created_by"
    t.string   "legacy_loan_id"
    t.string   "seq"
  end

  create_table "sic_codes", :force => true do |t|
    t.string  "code"
    t.string  "description"
    t.boolean "eligible",                 :default => false
    t.boolean "public_sector_restricted", :default => false
  end

  add_index "sic_codes", ["code"], :name => "index_sic_codes_on_code", :unique => true

  create_table "state_aid_calculations", :force => true do |t|
    t.integer  "loan_id",                                                                        :null => false
    t.integer  "initial_draw_year"
    t.integer  "initial_draw_amount",               :limit => 8,                                 :null => false
    t.integer  "initial_draw_months"
    t.integer  "initial_capital_repayment_holiday"
    t.integer  "second_draw_amount",                :limit => 8
    t.integer  "second_draw_months"
    t.integer  "third_draw_amount",                 :limit => 8
    t.integer  "third_draw_months"
    t.integer  "fourth_draw_amount",                :limit => 8
    t.integer  "fourth_draw_months"
    t.datetime "created_at",                                                                     :null => false
    t.datetime "updated_at",                                                                     :null => false
    t.string   "legacy_loan_id"
    t.integer  "seq"
    t.integer  "loan_version"
    t.string   "calc_type"
    t.string   "premium_cheque_month"
    t.integer  "holiday"
    t.integer  "total_cost"
    t.integer  "public_funding"
    t.boolean  "obj1_area"
    t.boolean  "reduce_costs"
    t.boolean  "improve_prod"
    t.boolean  "increase_quality"
    t.boolean  "improve_nat_env"
    t.boolean  "promote"
    t.boolean  "agriculture"
    t.integer  "guarantee_rate"
    t.decimal  "npv",                                            :precision => 2,  :scale => 1
    t.decimal  "prem_rate",                                      :precision => 2,  :scale => 1
    t.decimal  "euro_conv_rate",                                 :precision => 17, :scale => 14
    t.integer  "elsewhere_perc"
    t.integer  "obj1_perc"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
  end

  add_index "state_aid_calculations", ["legacy_loan_id"], :name => "index_state_aid_calculations_on_legacy_loan_id"
  add_index "state_aid_calculations", ["loan_id", "seq"], :name => "index_state_aid_calculations_on_loan_id_and_seq", :unique => true

  create_table "user_audits", :force => true do |t|
    t.integer  "user_id"
    t.string   "legacy_id"
    t.integer  "version"
    t.integer  "modified_by_id"
    t.string   "modified_by_legacy_id"
    t.string   "password"
    t.string   "function"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "user_audits", ["modified_by_id"], :name => "index_user_audits_on_modified_by_id"
  add_index "user_audits", ["user_id"], :name => "index_user_audits_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "lender_id"
    t.integer  "legacy_lender_id"
    t.integer  "version"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "disabled",               :default => false, :null => false
    t.string   "memorable_name"
    t.string   "memorable_place"
    t.string   "memorable_year"
    t.integer  "login_failures"
    t.datetime "password_changed_at"
    t.boolean  "locked",                 :default => false, :null => false
    t.string   "created_by_legacy_id"
    t.integer  "created_by_id"
    t.boolean  "confirm_t_and_c"
    t.string   "modified_by_legacy_id"
    t.integer  "modified_by_id"
    t.boolean  "knowledge_resource"
    t.string   "username",                                  :null => false
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.string   "type"
    t.integer  "failed_attempts",        :default => 0
    t.string   "legacy_email"
  end

  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["type"], :name => "index_users_on_type"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
